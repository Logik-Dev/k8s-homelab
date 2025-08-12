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

    endpoint                    = "https://s3.logikdev.fr"
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
  config_path = "../kubeconfig"
}

# Configure Helm Provider  
provider "helm" {
  kubernetes = {
    config_path = "../kubeconfig"
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
  vm_vcpu          = 4
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

