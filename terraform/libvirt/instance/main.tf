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
  }

  dynamic "disk" {
    for_each = var.volumes
    content {
      volume_id = disk.value.id
    }
  }

  dynamic "network_interface" {
    for_each = var.bridges
    content {
      bridge = network_interface.key
      mac    = network_interface.value
    }
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }
}

