# Infrastructure as Code

## Create cloud image template in Proxmox

Use the script as follows:

```sh
cd iac/
./create-proxmox-template.sh \
    root@pve-2 \
    https://cloud-images.ubuntu.com/jammy/20220924/jammy-server-cloudimg-amd64.img \
    8000 \
    ~/.ssh/id_ed25519.pub
```

## Deploy with Terraform

Export the following variables in the environment:

```sh
export PM_USER="terraform-prov@pve"
export PM_PASS="<PASS>"
```

Initialize Terraform providers and modules:

```sh
cd iac/terraform/
terraform init
```

Plan and apply, limiting parallelism because Proxmox API is slow and we want to avoid failures:

```sh
terraform plan
terraform apply -parallelism=1
```

## Set up K3s cluster with Ansible

The Ansible playbook and roles in this repository are based on [techno-tim's k3s-ansible repo](https://github.com/techno-tim/k3s-ansible) which is itself based on [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible).

The main differences are that I stripped it down to only what I needed, for learning purposes mostly, but also to be able to maintain it on my own.

This setup also does not use [MetalLB](https://metallb.org) for Kubernetes services `LoadBalancer` but instead uses [kube-vip](https://kube-vip.io) for both the control plane load balancing and the services load balancing, since it now supports it.

```sh
cd iac/ansible/
ansible-playbook stand-up-k3s.yml
```

To uninstall K3s:

```sh
ansible-playbook reset.yml
```

Then copy the config from one of the server nodes at `~/.kube/config`.

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