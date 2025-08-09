# Cluster configuration
locals {
  nodes = {
    "talos-cp-1" = {
      node_ip       = "10.0.100.101"
      vlan200_ip    = "10.0.200.101"
      machine_type  = "controlplane"
      hostname      = "talos1"
    }
    "talos-cp-2" = {
      node_ip       = "10.0.100.102"
      vlan200_ip    = "10.0.200.102"
      machine_type  = "controlplane"
      hostname      = "talos2"
    }
    "talos-cp-3" = {
      node_ip       = "10.0.100.103"
      vlan200_ip    = "10.0.200.103"
      machine_type  = "controlplane"
      hostname      = "talos3"
    }
  }
}

# VMs module
module "vms" {
  source = "./vms"

  vm_count         = var.vm_count
  vm_memory        = var.vm_memory
  vm_vcpu          = var.vm_vcpu
  ultra_pool_name  = var.ultra_pool_name
  talos_version    = var.talos_version
  iso_storage_path = var.iso_storage_path
  nodes            = local.nodes
}

# Talos module
module "talos" {
  source = "./talos"

  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  talos_version    = var.talos_version
  nodes            = local.nodes
  vm_ids           = module.vms.vm_ids
  schematic_id     = module.vms.schematic_id
}

# Cilium module
module "cilium" {
  source = "./cilium"

  kubeconfig_path    = "${path.root}/../kubeconfig"
  cilium_values_path = "${path.module}/cilium/values.yaml"

  depends_on = [module.talos]
}

# Flux module
module "flux" {
  source = "./flux"

  kubeconfig_path = "${path.root}/../kubeconfig"

  depends_on = [module.cilium]
}
