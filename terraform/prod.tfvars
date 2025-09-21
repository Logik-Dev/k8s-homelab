env = "prod"

pools = {
  local-prod = "/mnt/local/libvirt-pool/prod"
  ultra-prod = "/mnt/ultra/libvirt-pool/prod"
}

cluster_endpoint = "10.0.100.101"

image_pool = "local-prod"

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
        pool = "ultra-prod"
      }
      vdb-longhorn = {
        size = 900
        pool = "ultra-prod"
      }
    }
    xml = <<EOT
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Identité : copie tout le XML existant -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Match sur le noeud <devices> et injecte le hostdev -->
  <xsl:template match="devices">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>

      <!-- Ici on insère le hostdev GPU -->
      <hostdev mode="subsystem" type="pci" managed="yes">
        <source>
          <address domain="0x0000" bus="0x01" slot="0x00" function="0x0"/>
        </source>
      </hostdev>

    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
EOT
  }
}



