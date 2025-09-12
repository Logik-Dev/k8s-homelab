resource "libvirt_pool" "this" {
  for_each = var.pools
  name     = each.key
  type     = "dir"
  target {
    path = each.value
  }
}
