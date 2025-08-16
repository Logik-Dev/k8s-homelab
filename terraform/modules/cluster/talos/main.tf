
# Talos cluster configuration
resource "talos_machine_secrets" "cluster_secrets" {}

# Generate machine configurations
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.cluster_secrets.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.cluster_secrets.machine_secrets
}

# Apply configuration to controlplane nodes
resource "talos_machine_configuration_apply" "controlplane" {
  for_each = { for k, v in var.nodes : k => v if v.machine_type == "controlplane" }

  client_configuration        = talos_machine_secrets.cluster_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.node_ip
  config_patches = [
    file("${path.module}/patches/cni.yaml"),
    file("${path.module}/patches/dhcp.yaml"),
    file("${path.module}/patches/disks.yaml"),
    file("${path.module}/patches/extra-kernel-args.yaml"),
    file("${path.module}/patches/kubelet-certificates-rotation.yaml"),
    file("${path.module}/patches/metrics-server.yaml"),
    file("${path.module}/patches/nodes-subnet.yaml"),
    file("${path.module}/patches/vip.yaml"),
    file("${path.module}/patches/gateway-api-crds.yaml"),

    # define hostname and second ip
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/metal-installer/${var.schematic_id}:${var.talos_version}"
        }
        network = {
          hostname = each.value.hostname
          interfaces = [
            {
              interface = "eth1"
              addresses = ["${each.value.vlan200_ip}/24"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = "10.0.200.1"
                  metric  = 200
                }
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [var.vm_ids]
}

# Apply configuration to worker nodes
resource "talos_machine_configuration_apply" "worker" {
  for_each = { for k, v in var.nodes : k => v if v.machine_type == "worker" }

  client_configuration        = talos_machine_secrets.cluster_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.node_ip
  config_patches = [
    file("${path.module}/patches/cni.yaml"),
    file("${path.module}/patches/dhcp.yaml"),
    file("${path.module}/patches/disks.yaml"),
    file("${path.module}/patches/extra-kernel-args.yaml"),
    file("${path.module}/patches/kubelet-certificates-rotation.yaml"),
    file("${path.module}/patches/nodes-subnet.yaml"),
    file("${path.module}/patches/metrics-server.yaml"),
    file("${path.module}/patches/gateway-api-crds.yaml"),
    file("${path.module}/patches/volumes.yaml"),

    # define hostname and second ip
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/metal-installer/${var.schematic_id}:${var.talos_version}"
        }
        network = {
          hostname = each.value.hostname
          interfaces = [
            {
              interface = "eth1"
              addresses = ["${each.value.vlan200_ip}/24"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = "10.0.200.1"
                  metric  = 200
                }
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [var.vm_ids]
}

# Bootstrap the cluster
resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.cluster_secrets.client_configuration
  node                 = [for k, v in var.nodes : v.node_ip if k == "talos-cp-1"][0]

  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
}

# Get cluster kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.cluster_secrets.client_configuration
  node                 = [for k, v in var.nodes : v.node_ip if k == "talos-cp-1"][0]
}

# Get talos client configuration
data "talos_client_configuration" "client_config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster_secrets.client_configuration
  endpoints            = [for node in var.nodes : node.node_ip]
}
