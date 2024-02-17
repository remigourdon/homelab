terraform {
  cloud {
    organization = "remigourdon"
    workspaces {
      name = "homelab"
    }
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
  required_version = "~> 1.7.3"
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
  talos_iso = "nfs-isos:iso/talos-v1.6.4-metal-amd64.iso"
  pve_1_nodes = {
    "cluster-01" = {
      vm_id            = 301
      proxmox_node     = "pve-1"
      mac_address      = "74:3E:14:61:69:32"
      is_control_plane = true
    },
    "cluster-02" = {
      vm_id            = 302
      proxmox_node     = "pve-1"
      mac_address      = "82:6B:28:C2:F2:7C"
      is_control_plane = true
    },
  }
  pve_2_nodes = {
    "cluster-03" = {
      vm_id            = 303
      proxmox_node     = "pve-2"
      mac_address      = "96:CD:33:40:7B:DE"
      is_control_plane = true
    },
    "cluster-04" = {
      vm_id            = 304
      proxmox_node     = "pve-2"
      mac_address      = "A2:9F:15:C8:87:F6"
      is_control_plane = false
    },
    "cluster-05" = {
      vm_id            = 305
      proxmox_node     = "pve-2"
      mac_address      = "B6:DC:7E:00:F5:F9"
      is_control_plane = false
    }
  }
}

module "pve-1-nodes" {
  source   = "./modules/talos-node"
  for_each = local.pve_1_nodes
  providers = {
    proxmox = proxmox.pve1
  }
  name         = each.key
  description  = "K8s ${each.value.is_control_plane ? "control-plane" : "worker"}"
  proxmox_node = each.value.proxmox_node
  iso          = local.talos_iso
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = each.value.is_control_plane ? 2 : 4
  memory       = each.value.is_control_plane ? 2048 : 4096
}

module "pve-2-nodes" {
  source   = "./modules/talos-node"
  for_each = local.pve_2_nodes
  providers = {
    proxmox = proxmox.pve2
  }
  name         = each.key
  description  = "K8s ${each.value.is_control_plane ? "control-plane" : "worker"}"
  proxmox_node = each.value.proxmox_node
  iso          = local.talos_iso
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = each.value.is_control_plane ? 2 : 4
  memory       = each.value.is_control_plane ? 2048 : 4096
}
