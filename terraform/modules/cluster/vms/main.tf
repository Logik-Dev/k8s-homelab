# Get extensions versions for Talos Image Factory
data "talos_image_factory_extensions_versions" "cluster_extensions" {
  talos_version = var.talos_version
  filters = {
    names = [
      "i915-ucode",
      "iscsi-tools",
      "nonfree-kmod-nvidia-lts",
      "nvidia-container-toolkit-lts",
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

# Create additional local-nvme disks for workers only
resource "libvirt_volume" "vm_local_disk" {
  count  = length([for k, v in var.nodes : k if v.machine_type == "worker"])
  name   = "talos-local-worker-${count.index + 1}.qcow2"
  pool   = "local-pool"
  format = "qcow2"
  size   = 150 * 1024 * 1024 * 1024 # 150GB
}

# Create additional ultra-fast disks for workers only
resource "libvirt_volume" "vm_ultra_disk" {
  count  = length([for k, v in var.nodes : k if v.machine_type == "worker"])
  name   = "talos-ultra-worker-${count.index + 1}.qcow2"
  pool   = var.ultra_pool_name
  format = "qcow2"
  size   = 500 * 1024 * 1024 * 1024 # 500GB
}

# Create Controlplane VMs (OS disk only)
resource "libvirt_domain" "talos_controlplane" {
  for_each = { for k, v in var.nodes : k => v if v.machine_type == "controlplane" }
  
  name   = replace(each.key, "-", "-vm-")
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
  network_interface {
    bridge = "vlan100-talos"
    mac    = "52:54:00:10:01:01"  # Fixed MAC for controlplane
  }

  # Ingress interface on vlan200 
  network_interface {
    bridge = "vlan200-gateway"
  }

  # OS disk only for controlplane
  disk {
    volume_id = libvirt_volume.os_disk[0].id
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

# Create Worker VMs (OS + storage disks)
resource "libvirt_domain" "talos_worker" {
  count = length([for k, v in var.nodes : k if v.machine_type == "worker"])
  
  name   = "talos-vm-worker-${count.index + 1}"
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
  network_interface {
    bridge = "vlan100-talos"
    mac    = "52:54:00:10:01:0${count.index + 2}"  # Workers get .02, .03
  }

  # Ingress interface on vlan200 
  network_interface {
    bridge = "vlan200-gateway"
  }

  # OS disk (ultra-fast)
  disk {
    volume_id = libvirt_volume.os_disk[count.index + 1].id
  }

  # Ultra-fast disk for storage
  disk {
    volume_id = libvirt_volume.vm_ultra_disk[count.index].id
  }

  # Local-nvme disk for storage
  disk {
    volume_id = libvirt_volume.vm_local_disk[count.index].id
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

# Attach GPU to first worker via SSH
resource "null_resource" "attach_gpu_ssh" {
  # Only attach GPU to first worker
  count = 1

  # Trigger on VM changes or when GPU files change
  triggers = {
    worker_vm_id = libvirt_domain.talos_worker[0].id
    gpu_config   = filemd5("${path.module}/../../../gpu-devices.xml")
    audio_config = filemd5("${path.module}/../../../gpu-audio.xml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Copy GPU XML files to hypervisor
      scp ${path.module}/../../../gpu-devices.xml logikdev@192.168.10.100:/tmp/
      scp ${path.module}/../../../gpu-audio.xml logikdev@192.168.10.100:/tmp/
      
      # Check if GPU is already attached to avoid duplicate attachment
      if ! ssh logikdev@192.168.10.100 "sudo virsh dumpxml talos-vm-worker-1 | grep -q 'domain.*0x0000.*bus.*0x01.*slot.*0x00.*function.*0'"; then
        echo "Attaching GPU to talos-vm-worker-1..."
        # Attach GPU main device
        ssh logikdev@192.168.10.100 "sudo virsh attach-device talos-vm-worker-1 /tmp/gpu-devices.xml --persistent"
        # Attach GPU audio device  
        ssh logikdev@192.168.10.100 "sudo virsh attach-device talos-vm-worker-1 /tmp/gpu-audio.xml --persistent"
        echo "GPU attached successfully!"
      else
        echo "GPU already attached to talos-vm-worker-1"
      fi
      
      # Clean up temp files
      ssh logikdev@192.168.10.100 "rm -f /tmp/gpu-devices.xml /tmp/gpu-audio.xml"
    EOT
  }

  depends_on = [libvirt_domain.talos_worker]
}

# Apply NVIDIA configuration to first worker via talosctl
resource "null_resource" "apply_nvidia_config" {
  count = 1

  triggers = {
    worker_vm_id = libvirt_domain.talos_worker[0].id
    nvidia_patch = filemd5("${path.module}/../talos/patches/nvidia.yaml")
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Apply NVIDIA patch via talosctl directly
      talosctl patch machineconfig --nodes 10.0.100.102 --patch @${path.module}/../talos/patches/nvidia.yaml --talosconfig ../talosconfig
      
      echo "NVIDIA configuration applied to talos-worker-1"
    EOT
  }

  depends_on = [libvirt_domain.talos_worker, null_resource.attach_gpu_ssh]
}

# Create snapshots of controlplane VMs after initial creation
resource "null_resource" "controlplane_snapshots" {
  for_each = { for k, v in var.nodes : k => v if v.machine_type == "controlplane" }

  # Create snapshot after VM is created
  provisioner "local-exec" {
    command = "ssh hyper 'sudo virsh snapshot-create-as ${replace(each.key, "-", "-vm-")} initial-snapshot \"Initial snapshot after VM creation\"'"
  }

  depends_on = [libvirt_domain.talos_controlplane]
}

# Create snapshots of worker VMs after initial creation
resource "null_resource" "worker_snapshots" {
  count = length([for k, v in var.nodes : k if v.machine_type == "worker"])

  # Create snapshot after VM is created
  provisioner "local-exec" {
    command = "ssh hyper 'sudo virsh snapshot-create-as talos-vm-worker-${count.index + 1} initial-snapshot \"Initial snapshot after VM creation\"'"
  }

  depends_on = [libvirt_domain.talos_worker]
}
