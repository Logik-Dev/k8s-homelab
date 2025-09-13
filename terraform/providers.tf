terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.6.4"
    }
    sops = {
      source  = "nobbs/sops"
      version = "0.3.0"
    }
  }
}
provider "libvirt" {
  uri = var.libvirt_uri
}

provider "talos" {}

provider "http" {}

provider "local" {}

provider "null" {}

provider "kubectl" {
  client_certificate     = base64decode(module.talos_install.kubeconfig.client_certificate)
  cluster_ca_certificate = base64decode(module.talos_install.kubeconfig.ca_certificate)
  client_key             = base64decode(module.talos_install.kubeconfig.client_key)
  host                   = module.talos_install.kubeconfig.host
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_path
  }
}
provider "flux" {}

provider "sops" {}
