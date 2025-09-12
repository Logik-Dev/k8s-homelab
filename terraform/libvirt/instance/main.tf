resource "libvirt_domain" "this" {
  name       = var.name
  autostart  = true
  memory     = var.memory
  vcpu       = var.cpus
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  disk {
    file = var.cdrom_id
    scsi = false
  }

  dynamic "disk" {
    for_each = var.disks
    content {
      volume_id = disk.value.id
    }
  }

  dynamic "network_interface" {
    for_each = var.bridges
    content {
      bridge = network_interface.value
    }
  }

  dynamic "network_interface" {
    for_each = var.networks
    content {
      network_id     = network_interface.key
      addresses      = [network_interface.value.ipv4]
      wait_for_lease = true
    }
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }
}

