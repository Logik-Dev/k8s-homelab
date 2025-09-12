output "cilium_installation_id" {
  description = "ID of Cilium installation resource"
  value       = null_resource.install_cilium.id
}