data "talos_image_factory_urls" "this" {
  talos_version = "v1.11.0"
  schematic_id  = jsondecode(data.http.schematic.response_body).id
  platform      = "metal"
}
resource "libvirt_volume" "this" {
  name   = "talos-${var.env}.iso"
  pool   = var.pool
  source = data.talos_image_factory_urls.this.urls.iso
  format = "iso"
}

