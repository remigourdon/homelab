terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://pve-2.home.remigourdon.net:8006/api2/json"
  pm_debug        = true
  pm_tls_insecure = true
}

locals {
  nodes = {
    "k3s-01" = {
      vm_id       = 301
      mac_address = "74:3e:14:61:69:32"
    },
    "k3s-02" = {
      vm_id       = 302
      mac_address = "83:6b:28:c2:f2:7c"
    },
    "k3s-03" = {
      vm_id       = 303
      mac_address = "97:cd:33:40:7b:de"
    },
    "k3s-04" = {
      vm_id       = 304
      mac_address = "a2:9f:15:c8:87:f6"
    },
    "k3s-05" = {
      vm_id       = 305
      mac_address = "b6:dc:7e:00:f5:f9"
    }
  }
}

module "k3s-node" {
  for_each     = local.nodes
  source       = "./modules/k3s-node"
  name         = each.key
  proxmox_node = "pve-2"
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
}