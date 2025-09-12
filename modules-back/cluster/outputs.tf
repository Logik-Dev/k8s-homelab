output "kubeconfig_raw" {
  description = "Raw kubeconfig for the cluster"
  value       = module.talos.kubeconfig_raw
  sensitive   = true
}

output "talos_config" {
  description = "Talos client configuration"
  value       = module.talos.talos_config
  sensitive   = true
}