variable "name" {
  type        = string
  description = "Name of the K3s node VM"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to deploy VM onto"
}

variable "vm_id" {
  type        = number
  default     = 0
  description = "ID to use for the VM (0 uses next available)"
}

variable "mac_address" {
  type        = string
  description = "MAC address to use for the node's main interface"
}