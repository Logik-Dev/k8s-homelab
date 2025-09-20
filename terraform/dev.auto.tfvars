env = "dev"

pools = {
  local = "/mnt/local/libvirt-pool"
  ultra = "/mnt/ultra/libvirt-pool"
}

cluster_endpoint = "10.0.100.99"

instances = {
  talos1-dev = {
    type    = "controlplane"
    cpus    = 4
    memory  = "16384"
    ip      = "10.0.100.99"
    patches = ["allow-controlplane-workloads"]
    extensions = [
      "siderolabs/i915"
    ],
    bridges = {
      vlan100-talos   = "52:54:00:10:00:99",
      vlan200-gateway = null
      vlan21-iot      = null
    },
    volumes = {
      vda-os = {
        size = 50
        pool = "local"
      }
      vdb-longhorn = {
        size = 300
        pool = "local",
      }
    }
  }
}


