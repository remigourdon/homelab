variable "name" {
  type        = string
  description = "Name of the K3s node VM"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to deploy VM onto"
}

variable "mac_address" {
  type        = string
  description = "MAC address to use for the node's main interface"
}