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
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
  }
  required_version = "~> 1.7.3"
}

locals {
  cluster_endpoint = "https://${var.cluster_name}.${var.domain}:6443"
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

module "pve1-vms" {
  source   = "./modules/proxmox-vm"
  for_each = { for k, v in merge(var.nodes.controlplanes, var.nodes.workers) : k => v if v.proxmox_node == "pve-1" }

  providers = {
    proxmox = proxmox.pve1
  }

  name         = each.key
  description  = "K8s node"
  proxmox_node = each.value.proxmox_node
  iso          = var.talos_iso
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = contains(keys(var.nodes.controlplanes), each.key) ? 2 : 4
  memory       = contains(keys(var.nodes.controlplanes), each.key) ? 2048 : 4096
}

module "pve2-vms" {
  source   = "./modules/proxmox-vm"
  for_each = { for k, v in merge(var.nodes.controlplanes, var.nodes.workers) : k => v if v.proxmox_node == "pve-2" }

  providers = {
    proxmox = proxmox.pve2
  }

  name         = each.key
  description  = "K8s node"
  proxmox_node = each.value.proxmox_node
  iso          = var.talos_iso
  vm_id        = each.value.vm_id
  mac_address  = each.value.mac_address
  cores        = contains(keys(var.nodes.controlplanes), each.key) ? 2 : 4
  memory       = contains(keys(var.nodes.controlplanes), each.key) ? 2048 : 4096
}

resource "cloudflare_record" "a" {
  for_each = var.nodes.controlplanes
  zone_id  = "413c8a3d5eb7bb9bf47048173a04acaa"
  name     = var.cluster_name
  value    = each.value.ip_address
  type     = "A"
  ttl      = 3600
  proxied  = false
}

module "cluster" {
  source     = "./modules/talos-cluster"
  depends_on = [module.pve1-vms, module.pve2-vms]

  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  node_data        = var.nodes
}
