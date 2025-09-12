# Generate machine config
data "talos_machine_configuration" "this" {
  for_each         = var.machines
  talos_version    = var.talos_version
  cluster_name     = local.cluster_name
  machine_type     = each.value.type
  cluster_endpoint = "https://${var.cluster_endpoint}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

# Generate client config
data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.nodes
  endpoints            = [var.cluster_endpoint]
}

