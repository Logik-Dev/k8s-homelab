resource "libvirt_pool" "this" {
  name     =  var.name
  type     = "dir"
  target {
    path = var.path
  }
}
