output "kubeconfig_raw" {
  description = "Raw kubeconfig for the cluster"
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive   = true
}

output "talos_config" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.client_config.talos_config
  sensitive   = true
}