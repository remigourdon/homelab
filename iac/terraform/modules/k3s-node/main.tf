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
  vmid        = var.vm_id
  clone       = "jammy-server-cloudimg-amd64"
  full_clone  = true

  oncreate = true
  onboot   = true

  cores  = var.cores
  memory = var.memory

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

  # Cloud Init
  ciuser    = "server-admin"
  ipconfig0 = ",ip=dhcp"
  sshkeys   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItabw8pTiKUQn2EENw7EyTfXm/OgrpI7+Sc+hH2N8Ge remi@frame-home"
}
