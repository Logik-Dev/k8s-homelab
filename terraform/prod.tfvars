env = "prod"

libvirt_uri = "qemu+ssh://logikdev@hyper/system"

pools = {
  local-pool = "/mnt/storage/local"
  ultra-pool = "/mnt/storage/ultra"
}

image_pool = "local-pool"

cluster_endpoint = "10.0.100.101"

instances = {
  talos1 = {
    type   = "controlplane"
    cpus   = 4
    memory = "16384"
    patches = [
      "allow-controlplane-workloads",
      "nvidia"
    ]
    extensions = [
      "siderolabs/nvidia-container-toolkit-lts",
      "siderolabs/nonfree-kmod-nvidia-lts"
    ]
    networks = {
      k8s = {
        ipv4 = "10.0.100.101"
      }
    }
    volumes = {
      os = {
        size = 30
        pool = "local-pool"
      }
      data = {
        size = 50
        pool = "local-pool"
      }
    }
  }
}


