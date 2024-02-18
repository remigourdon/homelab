# Terraform

Terraform is used here to provision VMs on Proxmox and to bootstrap a Talos cluster on them.

## Documentation

+ Proxmox provider:
    + https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
    + https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/index.md
+ Talos provider:
    + https://registry.terraform.io/providers/siderolabs/talos/latest/docs
    + https://github.com/siderolabs/contrib/tree/main/examples/terraform


## Provide Terraform access to Proxmox

Create a Terraform user and role on the Proxmox server, as detailed [here](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform).

```sh
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

Configure the environment variables on the local machine where Terraform will be run:

```sh
export PM_USER="terraform-prov@pve"
export PM_PASS="<PASS>"
```