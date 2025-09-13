locals {
  kubeconfig_path  = "../${var.env}-kubeconfig"
  talosconfig_path = "../${var.env}-talosconfig"
}

# Create all storage pools
module "storage_pools" {
  for_each = var.pools
  source   = "./libvirt/pools"
  name     = each.key
  path     = each.value
}


# Create all instances volumes
module "vms_volumes" {
  for_each       = var.instances
  source         = "./libvirt/volumes"
  volumes        = each.value.volumes
  pools          = module.storage_pools
  volumes_prefix = each.key
}

# Construct Talos Image volumes
module "talos_image_volumes" {
  for_each   = var.instances
  source     = "./talos/image"
  pool       = module.storage_pools[var.image_pool].name
  extensions = each.value.extensions
}

# Create each vm
module "vms" {
  for_each = var.instances
  source   = "./libvirt/instance"
  name     = each.key
  cpus     = each.value.cpus
  memory   = each.value.memory
  volumes  = module.vms_volumes[each.key].volumes
  cdrom_id = module.talos_image_volumes[each.key].volume_id
  bridges  = each.value.bridges
}

# Install talos
module "talos_install" {
  source           = "./talos/install"
  env              = var.env
  instances_ids    = module.vms
  machines         = var.instances
  cluster_endpoint = var.cluster_endpoint
  common_patches   = var.common_patches
  installer_urls   = module.talos_image_volumes
  talosconfig_path = local.talosconfig_path
  kubeconfig_path  = local.kubeconfig_path
  cni_disabled     = var.cilium_enabled
}

# Deploy Gateway API CRDs
module "gateway_api_crds" {
  count              = var.cilium_enabled ? 1 : 0
  source             = "./gateway-api"
  manifest_urls      = var.gateway_api_crds
  kubeconfig         = module.talos_install.kubeconfig
  wait_for_apiserver = module.talos_install.ready
}

# Deploy cilium
module "cilium" {
  count            = var.cilium_enabled ? 1 : 0
  source           = "./cilium-cni"
  env              = var.env
  gateway_api_deps = module.gateway_api_crds[0].state
  kubeconfig_path  = local.kubeconfig_path
}

# Bootstrap FluxCD
module "flux" {
  source        = "./flux"
  kubeconfig    = module.talos_install.kubeconfig
  env           = var.env
  cluster_ready = module.talos_install.ready
}
