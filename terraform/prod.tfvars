env = "prod"

libvirt_uri = "qemu+ssh://logikdev@hyper/system"

pools = {
  local-pool = "/mnt/local/libvirt-pool"
  ultra-pool = "/mnt/ultra/libvirt-pool"
}

cluster_endpoint = "10.0.100.101"

instances = {
  talos1-prod = {
    type   = "controlplane"
    cpus   = 4
    memory = "32768"
    ip     = "10.0.100.101"
    patches = [
      "allow-controlplane-workloads",
      "nvidia"
    ]
    extensions = [
      "siderolabs/nvidia-container-toolkit-lts",
      "siderolabs/nonfree-kmod-nvidia-lts"
    ]
    bridges = {
      vlan100-talos   = "52:54:00:10:01:01",
      vlan200-gateway = null
      vlan21-iot      = null
    },
    volumes = {
      vda-os = {
        size = 30
        pool = "ultra-pool"
      }
      vdb-longhorn = {
        size = 900
        pool = "ultra-pool"
      }
    }
    xml = <<EOF
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
      </source>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </hostdev>
    EOF
  }
}



