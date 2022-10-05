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