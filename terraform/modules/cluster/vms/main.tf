# Get extensions versions for Talos Image Factory
data "talos_image_factory_extensions_versions" "cluster_extensions" {
  talos_version = var.talos_version
  filters = {
    names = [
      "i915-ucode",
      "iscsi-tools",
      "qemu-guest-agent",
      "util-linux-tools"
    ]
  }
}

# Create Image Factory schematic with system extensions
resource "talos_image_factory_schematic" "cluster_schematic" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.cluster_extensions.extensions_info.*.name
        }
      }
    }
  )
}

# Download Talos ISO from Image Factory using generated schematic
resource "null_resource" "download_talos_iso" {
  triggers = {
    talos_version = var.talos_version
    schematic_id  = talos_image_factory_schematic.cluster_schematic.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      ssh hyper "sudo mkdir -p ${var.iso_storage_path}"
      ssh hyper "sudo wget -O ${var.iso_storage_path}/talos-${var.talos_version}-metal-amd64.iso https://factory.talos.dev/image/${talos_image_factory_schematic.cluster_schematic.id}/${var.talos_version}/metal-amd64.iso"
      ssh hyper "sudo chmod 644 ${var.iso_storage_path}/talos-${var.talos_version}-metal-amd64.iso"
    EOT
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
  size   = 150 * 1024 * 1024 * 1024 # 100GB
}

# Create additional ultra-fast disks
resource "libvirt_volume" "vm_ultra_disk" {
  count  = var.vm_count
  name   = "talos-ultra-${count.index + 1}.qcow2"
  pool   = var.ultra_pool_name
  format = "qcow2"
  size   = 500 * 1024 * 1024 * 1024 # 100GB
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

  # Boot configuration - boot from Hard disk and fallback to CD-ROM
  boot_device {
    dev = ["hd", "cdrom"]
  }

  # Kubernetes network interface
  # Ip is reserved by my router
  network_interface {
    bridge = "vlan100-talos"
    mac        = "52:54:00:10:01:0${count.index + 1}"
  }

  # Ingress interface on vlan200 
  # Ip is set in config patches 
  network_interface {
    bridge = "vlan200-gateway"
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
    file = "${var.iso_storage_path}/talos-${var.talos_version}-metal-amd64.iso"
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

  depends_on = [null_resource.download_talos_iso]
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
