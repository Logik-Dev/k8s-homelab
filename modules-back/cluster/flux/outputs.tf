output "flux_installation_id" {
  description = "ID of Flux installation resource"
  value       = null_resource.bootstrap_flux.id
}