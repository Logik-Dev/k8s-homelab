env = "dev"

libvirt_uri = "qemu:///system"

pools = {
  local-pool = "/var/lib/libvirt/pools/local-pool"
}

nat_networks = {
  "k8s" = {
    subnets = ["10.0.99.0/24"]
  }
}

cluster_endpoint = "10.0.99.101"

instances = {
  talos1 = {
    type       = "controlplane"
    cpus       = 4
    memory     = "4096"
    patches    = ["allow-controlplane-workloads"]
    extensions = []
    networks = {
      k8s = {
        ipv4 = "10.0.99.101"
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


