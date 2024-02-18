variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "talos_iso" {
  type        = string
  description = "Talos ISO to use in Proxmox"
}

variable "nodes" {
  description = "Cluster node configuration"
  type = object({
    controlplanes = map(object({
      vm_id        = number
      proxmox_node = string
      mac_address  = string
      ip_address   = string
    }))
    workers = map(object({
      vm_id        = number
      proxmox_node = string
      mac_address  = string
      ip_address   = string
    }))
  })
}
