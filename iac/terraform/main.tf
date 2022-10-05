terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
    }
  }
}

# Proxmox server on HPE Proliant
provider "proxmox" {
  alias           = "pve1"
  pm_api_url      = "https://pve-1.home.remigourdon.net:8006/api2/json"
  pm_debug        = true
  pm_tls_insecure = true
}

# Proxmox server on Intel NUC
provider "proxmox" {
  alias           = "pve2"
  pm_api_url      = "https://pve-2.home.remigourdon.net:8006/api2/json"
  pm_debug        = true
  pm_tls_insecure = true
}

locals {
  pve_1_nodes = {
    "k3s-01" = {
      vm_id         = 301
      proxmox_node  = "pve-1"
      mac_address   = "74:3E:14:61:69:32"
      is_k3s_server = true
    },
    "k3s-02" = {
      vm_id         = 302
      proxmox_node  = "pve-1"
      mac_address   = "82:6B:28:C2:F2:7C"
      is_k3s_server = true
    },
  }
  pve_2_nodes = {
    "k3s-03" = {
      vm_id         = 303
      proxmox_node  = "pve-2"
      mac_address   = "96:CD:33:40:7B:DE"
      is_k3s_server = true
    },
    "k3s-04" = {
      vm_id         = 304
      proxmox_node  = "pve-2"
      mac_address   = "A2:9F:15:C8:87:F6"
      is_k3s_server = false
    },
    "k3s-05" = {
      vm_id         = 305
      proxmox_node  = "pve-2"
      mac_address   = "B6:DC:7E:00:F5:F9"
      is_k3s_server = false
    }
  }
}

module "pve-1-nodes" {
  source   = "./modules/k3s-node"
  for_each = local.pve_1_nodes
  providers = {
    proxmox = proxmox.pve1
  }
  name         = each.key
  description  = "K3s ${each.value.is_k3s_server ? "server" : "agent"}"
  proxmox_node = each.value.proxmox_node
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = each.value.is_k3s_server ? 2 : 4
  memory       = each.value.is_k3s_server ? 2048 : 4096
}

module "pve-2-nodes" {
  source   = "./modules/k3s-node"
  for_each = local.pve_2_nodes
  providers = {
    proxmox = proxmox.pve2
  }
  name         = each.key
  description  = "K3s ${each.value.is_k3s_server ? "server" : "agent"}"
  proxmox_node = each.value.proxmox_node
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = each.value.is_k3s_server ? 2 : 4
  memory       = each.value.is_k3s_server ? 2048 : 4096
}
