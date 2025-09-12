# Storage pools module
resource "libvirt_pool" "ultra_pool" {
  name = "ultra-pool"
  type = "dir"
  target {
    path = "/mnt/ultra/libvirt"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "libvirt_pool" "local_pool" {
  name = "local-pool"
  type = "dir"
  target {
    path = "/mnt/local/libvirt"
  }
  lifecycle {
    prevent_destroy = true
  }
}