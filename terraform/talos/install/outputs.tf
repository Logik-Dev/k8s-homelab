output "kubeconfig" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration
}
