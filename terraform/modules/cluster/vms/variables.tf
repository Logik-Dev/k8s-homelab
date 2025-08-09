variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
}

variable "vm_memory" {
  description = "Memory for each VM in MB"
  type        = number
}

variable "vm_vcpu" {
  description = "Number of vCPUs for each VM"
  type        = number
}

variable "ultra_pool_name" {
  description = "Name of the ultra storage pool"
  type        = string
}

variable "talos_version" {
  description = "Talos Linux version"
  type        = string
}

variable "iso_storage_path" {
  description = "Storage path for downloaded ISO on hypervisor"
  type        = string
}


variable "nodes" {
  description = "Node configuration"
  type = map(object({
    node_ip       = string
    vlan200_ip    = string
    machine_type  = string
    hostname      = string
  }))
}
