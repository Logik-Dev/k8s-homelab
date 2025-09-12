resource "libvirt_network" "this" {
  for_each  = var.nat_networks
  mode      = "nat"
  name      = each.key
  addresses = each.value.subnets
  autostart = true
}

