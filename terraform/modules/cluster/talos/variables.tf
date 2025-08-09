variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster endpoint URL"
  type        = string
}

variable "talos_version" {
  description = "Talos Linux version"
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

variable "vm_ids" {
  description = "VM IDs from VMs module"
  type        = list(string)
}

variable "schematic_id" {
  description = "Talos Image Factory schematic ID from VMs module"
  type        = string
}
