# Homelab

## K3s and Ansible

The Ansible playbook and roles in this repository are based on [techno-tim's k3s-ansible repo](https://github.com/techno-tim/k3s-ansible) which is itself based on [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible).

The main differences are that I stripped it down to only what I needed, for learning purposes mostly, but also to be able to maintain it on my own.

This setup also does not use [MetalLB](https://metallb.org) for Kubernetes services `LoadBalancer` but instead uses [kube-vip](https://kube-vip.io) for both the control plane load balancing and the services load balancing, since it now supports it.

## Initial steps

### Create VM Template

Proxmox is currently my hypervisor of choice, and in my current lab setup I have it running on 2 nodes (`pve-1` and `pve-2`).

The Ubuntu template that I use for my VMs is created as follows, using the script `iac/create-proxmox-template.sh`.

```sh
./iac/create-proxmox-template.sh \
    root@pve-2 \
    https://cloud-images.ubuntu.com/jammy/20220924/jammy-server-cloudimg-amd64.img \
    8000 \
    ~/.ssh/id_ed25519.pub
```

### Provide Terraform access to Proxmox

Create a Terraform user and role on the Proxmox server, as detailed [here](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform).

```sh
pveum role add TerraformProv -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

Configure the environment variables on the local machine where Terraform will be run:

```sh
export PM_USER="terraform-prov@pve"
export PM_PASS="<PASS>"
```

## Stand up cluster

To stand up the cluster run `make` from the root of this repository.
This will:

+ Install Python dependencies for Ansible
+ Create the VMs using Terraform
+ Deploy K3s on the VMs using Ansible

Then copy the config from one of the server nodes and set up the `KUBECONFIG` environment variable:

```sh
scp k3s-01:~/.kube/lab-config ~/.kube/lab-config
export KUBECONFIG="$HOME/.kube/lab-config"
kubectl cluster-info
```

## Bootstrap Flux

Flux is used for GitOps and is bootstrapped as follows, following the instructions [on this page](https://fluxcd.io/flux/installation/#github-and-github-enterprise):

```sh
export GITHUB_TOKEN=<your-token>
flux bootstrap github \
    --owner=remigourdon \
    --repository=homelab \
    --path=clusters/lab \
    --personal \
    --private
```

[Age](https://github.com/FiloSottile/age) is used with [Mozilla SOPS](https://github.com/mozilla/sops) to encrypt secrets, as described on [this page](https://fluxcd.io/flux/guides/mozilla-sops/#encrypting-secrets-using-age).

The private key should be retrieved from the safe storage and a secret should be created from it after bootstrapping the cluster, as follows:

```sh
cat age.agekey |
    kubectl create secret generic sops-age \
        --namespace=flux-system \
        --from-file=age.agekey=/dev/stdin
```

Secrets can be encrypted as follows:

```sh
sops \
    --config clusters/lab/.sops.yaml \
	--encrypt \
	--in-place my-secret.yaml
```

## Test load balancers

### Control plane

To test the control plane load balancer, we can turn off each server nodes off alternatively and pinging the IP configured for `kube_vip_ip` in `iac/ansible/group_vars/k3s_cluster.yml`.

That is because we the current setup of 3 server nodes, kube-vip allows us to loose at most 1 node at a time.

Turning off 2 nodes will render the control plane unreachable.

### Service

To test the service load balancer we can deploy the `podinfo` test application as follows:

```sh
kubectl apply --kustomize iac/podinfo
```

This will apply the `service.yaml` and `deployment.yaml` copied from the [podinfo repository](https://github.com/stefanprodan/podinfo) as well as some patches to use the load balancer and have 2 replicas (one for each K3s agent node).
The patches are defined using Kustomize in `iac/podinfo/kustomization.yaml`.

If all works well then running `kubectl get services podinfo` should show an external IP from the pool defined in `iac/ansible/group_vars/k3s_cluster.yml` as `kube_vip_cloud_controller_ip_range` and the `podinfo` application should be accessible at that IP on port `9898`.

If the `podinfo` needs to be removed, this can be done with: `kubectl delete --kustomize iac/podinfo`.