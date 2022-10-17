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