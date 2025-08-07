# Cluster configuration
locals {
  nodes = {
    "talos-cp-1" = {
      node_ip      = "10.0.100.101"
      machine_type = "controlplane"
    }
    "talos-cp-2" = {
      node_ip      = "10.0.100.102"
      machine_type = "controlplane"
    }
    "talos-cp-3" = {
      node_ip      = "10.0.100.103"
      machine_type = "controlplane"
    }
  }
}

# Create OS disks for VMs
resource "libvirt_volume" "os_disk" {
  count  = var.vm_count
  name   = "talos-os-${count.index + 1}.qcow2"
  pool   = var.ultra_pool_name
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024 # 50GB
}

# Create additional local-nvme disks
resource "libvirt_volume" "vm_local_disk" {
  count  = var.vm_count
  name   = "talos-local-${count.index + 1}.qcow2"
  pool   = "local-pool"
  format = "qcow2"
  size   = 100 * 1024 * 1024 * 1024 # 100GB
}

# Create additional ultra-fast disks
resource "libvirt_volume" "vm_ultra_disk" {
  count  = var.vm_count
  name   = "talos-ultra-${count.index + 1}.qcow2"
  pool   = var.ultra_pool_name
  format = "qcow2"
  size   = 100 * 1024 * 1024 * 1024 # 100GB
}

# Create VMs
resource "libvirt_domain" "talos_vm" {
  count  = var.vm_count
  name   = "talos-vm-${count.index + 1}"
  memory = var.vm_memory
  vcpu   = var.vm_vcpu

  # CPU configuration - use host CPU features
  cpu {
    mode = "host-passthrough"
  }

  xml {
    xslt = <<EOF
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="yes"/>
      <xsl:template match="@*|node()">
        <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
      </xsl:template>

      <xsl:template match="cpu">
        <cpu>
          <xsl:copy-of select="@*"/>
          <topology sockets="1" cores="${var.vm_vcpu}" threads="1"/>
          <xsl:apply-templates select="node()"/>
        </cpu>
      </xsl:template>
    </xsl:stylesheet>
    EOF
  }

  # Boot configuration - boot from Hard disk and fallback to CD-ROM
  boot_device {
    dev = ["hd", "cdrom"]
  }

  # Kubernetes network interface
  network_interface {
    bridge = "vlan100-talos"
    mac    = "52:54:00:10:01:0${count.index + 1}"
  }

  # OS disk (ultra-fast)
  disk {
    volume_id = libvirt_volume.os_disk[count.index].id
  }

  # Local-nvme disk
  disk {
    volume_id = libvirt_volume.vm_local_disk[count.index].id
  }

  # Ultra-fast disk
  disk {
    volume_id = libvirt_volume.vm_ultra_disk[count.index].id
  }

  # CD-ROM with Talos ISO
  disk {
    file = var.iso_path
  }

  # Console access
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Create snapshots of VMs after initial creation
resource "null_resource" "vm_snapshots" {
  count = var.vm_count

  # Create snapshot after VM is created
  provisioner "local-exec" {
    command = "ssh hyper 'sudo virsh snapshot-create-as talos-vm-${count.index + 1} initial-snapshot \"Initial snapshot after VM creation\"'"
  }

  depends_on = [libvirt_domain.talos_vm]
}

# Talos cluster configuration
resource "talos_machine_secrets" "cluster_secrets" {}

# Generate machine configurations
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.cluster_secrets.machine_secrets

  config_patches = [
    file("${path.root}/talos/patches/allow-controlplane-workloads.yaml"),
    file("${path.root}/talos/patches/cni.yaml"),
    file("${path.root}/talos/patches/dhcp.yaml"),
    file("${path.root}/talos/patches/disks.yaml"),
    file("${path.root}/talos/patches/extra-kernel-args.yaml"),
    file("${path.root}/talos/patches/nodes-subnet.yaml"),
    file("${path.root}/talos/patches/vip.yaml"),
    file("${path.root}/talos/patches/gateway-api-crds.yaml")
  ]
}

# Apply configuration to nodes
resource "talos_machine_configuration_apply" "controlplane" {
  for_each = local.nodes

  client_configuration        = talos_machine_secrets.cluster_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.node_ip

  depends_on = [libvirt_domain.talos_vm]
}

# Bootstrap the cluster
resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.cluster_secrets.client_configuration
  node                 = local.nodes["talos-cp-1"].node_ip

  depends_on = [talos_machine_configuration_apply.controlplane]
}

# Get cluster kubeconfig
resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.cluster_secrets.client_configuration
  node                 = local.nodes["talos-cp-1"].node_ip
}

# Get talos client configuration
data "talos_client_configuration" "client_config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster_secrets.client_configuration
  endpoints            = [for node in local.nodes : node.node_ip]
}
