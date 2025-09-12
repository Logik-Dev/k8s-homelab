resource "libvirt_volume" "this" {
  for_each = var.volumes
  name     = "${var.volumes_prefix}-${each.key}"
  pool     = var.pools[each.value.pool].name
  size     = each.value.size * 1024 * 1024 * 1024
}

