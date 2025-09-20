locals {
  cluster_endpoint = "https://${var.cluster_endpoint}:6443"
}
# Generate machine config
data "talos_machine_configuration" "this" {
  for_each         = var.machines
  talos_version    = var.talos_version
  cluster_name     = local.cluster_name
  machine_type     = each.value.type
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

# Generate client config
data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.nodes
  endpoints            = [var.cluster_endpoint]
}

# Cluster Readiness
data "talos_cluster_health" "this" {
  depends_on = [ talos_machine_configuration_apply.this ]
  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes = [var.cluster_endpoint]
  endpoints           = data.talos_client_configuration.this.endpoints
}
