output "kubeconfig" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration
}

output "ready" {
  value = data.talos_cluster_health.this.id
}