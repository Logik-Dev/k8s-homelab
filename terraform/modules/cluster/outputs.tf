output "kubeconfig_raw" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

output "talos_config" {
  value     = data.talos_client_configuration.client_config.talos_config
  sensitive = true
}