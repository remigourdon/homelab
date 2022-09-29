terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://pve-1.home.remigourdon.net:8006/api2/json"
  pm_debug        = true
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "resource-name" {
  name        = "ubuntu-test"
  target_node = "pve-1"
  clone       = "jammy-server-cloudimg-amd64"
  full_clone  = true
}