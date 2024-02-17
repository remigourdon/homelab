terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

resource "proxmox_vm_qemu" "talos-node" {
  name = var.name
  desc = var.description

  target_node = var.proxmox_node
  vmid        = var.vm_id
  iso         = var.iso

  vm_state = "running"
  onboot   = true

  cores  = var.cores
  memory = var.memory

  scsihw = "virtio-scsi-pci"
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-zfs"
          size    = var.disk_size
        }
      }
    }
  }

  network {
    model   = "virtio"
    macaddr = var.mac_address
    bridge  = "vmbr0"
  }
}
