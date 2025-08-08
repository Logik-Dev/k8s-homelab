# Variables for cluster configuration
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
}

variable "vm_memory" {
  description = "Memory for each VM in MB"
  type        = number
  default     = 16384 # 16 GiB
}

variable "vm_vcpu" {
  description = "Number of vCPUs for each VM"
  type        = number
  default     = 4
}

variable "talos_version" {
  description = "Talos Linux version"
  type        = string
  default     = "v1.10.6"
}


variable "iso_storage_path" {
  description = "Storage path for downloaded ISO on hypervisor"
  type        = string
  default     = "/mnt/local/libvirt/"
}

variable "ultra_pool_name" {
  description = "Name of the ultra storage pool"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "talos"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint URL"
  type        = string
  default     = "https://10.0.10.100:6443"
}
