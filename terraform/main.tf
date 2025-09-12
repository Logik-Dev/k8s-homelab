locals {
  kubeconfig_path  = "../${var.env}-kubeconfig"
  talosconfig_path = "../${var.env}-talosconfig"
}
# Create all pools
module "pools" {
  source = "./libvirt/pools"
  pools  = var.pools
}

# Create all networks
module "nat_networks" {
  source       = "./libvirt/networks"
  nat_networks = var.nat_networks
}

# Create all instances volumes
module "volumes" {
  for_each       = var.instances
  source         = "./libvirt/volumes"
  volumes        = each.value.volumes
  pools          = module.pools.pools
  volumes_prefix = each.key
}

# Construct Talos Image
module "image" {
  for_each   = var.instances
  source     = "./talos/image"
  pool       = module.pools.pools[var.image_pool].name
  extensions = each.value.extensions
}

# Create each instance
module "instances" {
  for_each = var.instances
  source   = "./libvirt/instance"
  name     = each.key
  cpus     = each.value.cpus
  memory   = each.value.memory
  disks    = module.volumes[each.key].volumes
  cdrom_id = module.image[each.key].volume_id
  networks = { for k, v in each.value.networks : module.nat_networks.nat_networks[k].id => { ipv4 = v.ipv4 } }
}

# Install talos
module "install" {
  source           = "./talos/install"
  env              = var.env
  ips              = module.instances
  machines         = var.instances
  cluster_endpoint = var.cluster_endpoint
  common_patches   = var.common_patches
  installer_urls   = module.image
  talosconfig_path = local.talosconfig_path
  kubeconfig_path  = local.kubeconfig_path
}

# Deploy Gateway API CRDs
module "gateway_api_crds" {
  source        = "./gateway-api"
  manifest_urls = var.gateway_api_crds
  kubeconfig    = module.install.kubeconfig
}

# Deploy cilium
module "cilium" {
  source           = "./cilium-cni"
  env              = var.env
  gateway_api_deps = module.gateway_api_crds.state
  kubeconfig_path  = local.kubeconfig_path
}

# Bootstrap FluxCD
module "flux" {
  source      = "./flux"
  cilium_deps = module.cilium
  kubeconfig  = module.install.kubeconfig
  env         = var.env
}

