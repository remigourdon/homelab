terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "proxmox_vm_qemu" "this" {
  name = var.name
  desc = var.description

  target_node = var.proxmox_node
  vmid        = var.vm_id
  iso         = var.iso

  oncreate = true
  onboot   = true

  cores  = var.cores
  memory = var.memory

  qemu_os = "l26"
  agent   = 0

  scsihw = "virtio-scsi-pci"
  disk {
    type    = "scsi"
    storage = "local-zfs"
    size    = var.disk_size
  }

  network {
    model   = "virtio"
    macaddr = var.mac_address
    bridge  = "vmbr0"
  }
}
