terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
  }
}

resource "proxmox_vm_qemu" "k3s-node" {
  name        = var.name
  target_node = var.proxmox_node
  clone       = "jammy-server-cloudimg-amd64"
  full_clone  = true

  oncreate = true
  onboot   = true

  cores  = 4
  memory = 4096

  scsihw = "virtio-scsi-pci"
  disk {
    type    = "scsi"
    storage = "local-zfs"
    size    = "10G"
  }

  network {
    model   = "virtio"
    macaddr = var.mac_address
    bridge  = "vmbr0"
  }
}
