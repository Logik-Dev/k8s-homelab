
locals {
  cluster_name = "talos-${var.env}"
  nodes        = [for v in var.ips : v.ip]
  tailscale = templatefile(
    "${path.module}/patches/tailscale.tftpl",
    {
      tskey = provider::sops::file("${path.module}/secrets.yaml").data["tailscale-${var.env}"]
    }
  )
}

# Generate secrets
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# Apply configs on each node
resource "talos_machine_configuration_apply" "this" {
  for_each                    = var.machines
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = var.ips[each.key].ip
  config_patches = concat(
    [local.tailscale],
    [for patch in var.common_patches : file("${path.module}/patches/${patch}.yaml")],
    [for patch in each.value.patches : file("${path.module}/patches/${patch}.yaml")],
    [yamlencode({
      machine = {
        install = {
          image = var.installer_urls[each.key].installer_url
        }
      }
    })]
  )
}

# Bootstrap cluster on controlplane
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = var.cluster_endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
}

# Generate kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.cluster_endpoint
}
# Generate talosconfig
resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = var.talosconfig_path
}

# Generate talosconfig
resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = var.kubeconfig_path
}
