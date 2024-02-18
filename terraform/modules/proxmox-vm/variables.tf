variable "name" {
  type        = string
  description = "Name of the VM"
}

variable "description" {
  type        = string
  description = "Description of the VM"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to deploy VM onto"
}

variable "iso" {
  type        = string
  description = "The name of the ISO image to mount to the VM"
}

variable "vm_id" {
  type        = number
  default     = 0
  description = "ID to use for the VM (0 uses next available)"
}

variable "mac_address" {
  type        = string
  description = "MAC address to use for the VM's main interface"
}

variable "cores" {
  type        = number
  description = "CPU cores to dedicate to the VM"
  default     = 4
}

variable "memory" {
  type        = number
  description = "Memory to dedicate to the VM (in MB)"
  default     = 4096
}

variable "disk_size" {
  type        = string
  description = "Disk size for the VM"
  default     = "10G"
}
