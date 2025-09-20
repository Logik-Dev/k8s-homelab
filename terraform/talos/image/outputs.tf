output "volume_id" {
  value = libvirt_volume.this.id
}

output "installer_url" {
  value = data.talos_image_factory_urls.this.urls.installer
}
