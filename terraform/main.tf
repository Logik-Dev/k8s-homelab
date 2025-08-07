terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }

  backend "s3" {
    bucket = "opentofu"
    key    = "k8s-homelab/terraform.tfstate"
    region = "us-east-1"

    endpoint                    = "http://192.168.10.100:9000"
    use_path_style              = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

# Configure the Libvirt Provider
provider "libvirt" {
  uri = "qemu+ssh://logikdev@hyper/system"
}

# Configure the Talos Provider
provider "talos" {}

# Configure Kubernetes Provider
provider "kubernetes" {
  config_path = fileexists("../kubeconfig") ? "../kubeconfig" : null
}

# Configure Helm Provider  
provider "helm" {
  kubernetes =  {
    config_path = fileexists("../kubeconfig") ? "../kubeconfig" : null
  }
}

# Storage pools module
module "pools" {
  source = "./modules/pools"
}

# Cluster module
module "cluster" {
  source = "./modules/cluster"

  ultra_pool_name  = module.pools.ultra_pool_name
  vm_count         = 3
  vm_memory        = 16384 # 16 GiB
  vm_vcpu          = 2
  iso_path         = "/mnt/local/libvirt/talos-metal.iso"
  cluster_name     = "talos"
  cluster_endpoint = "https://10.0.100.100:6443"
}

# Output kubeconfig
resource "local_file" "kubeconfig" {
  content  = module.cluster.kubeconfig_raw
  filename = "../kubeconfig"
}

# Output talosconfig
resource "local_file" "talosconfig" {
  content  = module.cluster.talos_config
  filename = "../talosconfig"
}

resource "null_resource" "install_cilium" {
  depends_on = [
    module.cluster,
    local_file.kubeconfig
  ]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "🔄 Uninstalling Cilium before cluster is destroyed..."
      export KUBECONFIG=.${path.module}/kubeconfig
      cilium uninstall --wait
    EOT
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      set -e

      export KUBECONFIG=.${path.module}/kubeconfig

      echo "🔍 Waiting for Kubernetes API..."
      for i in {1..60}; do
        if kubectl cluster-info > /dev/null 2>&1; then
          echo "✅ Kubernetes API ready"
          break
        fi
        echo "⏳ Try $i: API not ready, waiting..."
        sleep 5
      done

      echo "🚀 Installing Cilium..."
      cilium install --version 1.17.6 --values ${path.module}/cilium/values.yaml
    EOT
    working_dir = "${path.module}"
  }
}
