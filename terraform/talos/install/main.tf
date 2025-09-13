
locals {
  cluster_name = "talos-${var.env}"
  nodes        = [for v in var.machines : v.ip]
  tailscale = templatefile("${path.module}/patches/tailscale.tftpl",
    {
      tskey = provider::sops::file("${path.module}/secrets.yaml").data["tailscale-${var.env}"]
    }
  )
  disable_cni_patch = var.cni_disabled ? [file("${path.module}/patches/no-cni.yaml")] : []
}

# Generate secrets
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# Apply configs on each node
resource "talos_machine_configuration_apply" "this" {
  for_each                    = var.machines
  depends_on                  = [var.instances_ids]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = var.machines[each.key].ip
  config_patches = concat(
    # Enable/Disable CNI
    local.disable_cni_patch,
    # Tailscale
    [local.tailscale],
    # Common patches
    [for patch in var.common_patches : file("${path.module}/patches/${patch}.yaml")],
    # Extra patches
    [for patch in each.value.patches : file("${path.module}/patches/${patch}.yaml")],
    # Hostname and installer
    [yamlencode({
      machine = {
        network = {
          hostname = each.key
        }
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
