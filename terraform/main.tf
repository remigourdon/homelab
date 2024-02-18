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
      version = "2.9.14"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
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

provider "cloudflare" {}

locals {
  cluster_name = "clarke"
  talos_iso    = "nfs-isos:iso/talos-v1.6.4-metal-amd64.iso"

  controlplanes = {
    "clarke-01" = {
      vm_id        = 301
      proxmox_node = "pve-1"
      mac_address  = "74:3E:14:61:69:32"
      ip_address   = "192.168.50.51"
    },
    "clarke-02" = {
      vm_id        = 302
      proxmox_node = "pve-1"
      mac_address  = "82:6B:28:C2:F2:7C"
      ip_address   = "192.168.50.52"
    },
    "clarke-03" = {
      vm_id        = 303
      proxmox_node = "pve-2"
      mac_address  = "96:CD:33:40:7B:DE"
      ip_address   = "192.168.50.53"
    }
  }
  workers = {
    "clarke-04" = {
      vm_id        = 304
      proxmox_node = "pve-2"
      mac_address  = "A2:9F:15:C8:87:F6"
      ip_address   = "192.168.50.54"
    },
    "clarke-05" = {
      vm_id        = 305
      proxmox_node = "pve-2"
      mac_address  = "B6:DC:7E:00:F5:F9"
      ip_address   = "192.168.50.55"
    }
  }
}

module "pve1-vms" {
  source   = "./modules/proxmox-vm"
  for_each = { for k, v in merge(local.controlplanes, local.workers) : k => v if v.proxmox_node == "pve-1" }

  providers = {
    proxmox = proxmox.pve1
  }

  name         = each.key
  description  = "K8s node"
  proxmox_node = each.value.proxmox_node
  iso          = local.talos_iso
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = contains(keys(local.controlplanes), each.key) ? 2 : 4
  memory       = contains(keys(local.controlplanes), each.key) ? 2048 : 4096
}

module "pve2-vms" {
  source   = "./modules/proxmox-vm"
  for_each = { for k, v in merge(local.controlplanes, local.workers) : k => v if v.proxmox_node == "pve-2" }

  providers = {
    proxmox = proxmox.pve2
  }

  name         = each.key
  description  = "K8s node"
  proxmox_node = each.value.proxmox_node
  iso          = local.talos_iso
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = contains(keys(local.controlplanes), each.key) ? 2 : 4
  memory       = contains(keys(local.controlplanes), each.key) ? 2048 : 4096
}

resource "cloudflare_record" "a" {
  for_each = local.controlplanes
  zone_id  = "413c8a3d5eb7bb9bf47048173a04acaa"
  name     = local.cluster_name
  value    = each.value.ip_address
  type     = "A"
  ttl      = 3600
  proxied  = false
}
