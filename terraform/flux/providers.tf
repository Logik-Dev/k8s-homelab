terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "1.6.4"
    }
    sops = {
      source  = "nobbs/sops"
      version = "0.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
provider "kubectl" {
  client_certificate     = base64decode(var.kubeconfig.client_certificate)
  cluster_ca_certificate = base64decode(var.kubeconfig.ca_certificate)
  client_key             = base64decode(var.kubeconfig.client_key)
  host                   = var.kubeconfig.host
  load_config_file       = false
}

provider "flux" {
  kubernetes = {
    client_certificate     = base64decode(var.kubeconfig.client_certificate)
    cluster_ca_certificate = base64decode(var.kubeconfig.ca_certificate)
    client_key             = base64decode(var.kubeconfig.client_key)
    host                   = var.kubeconfig.host
  }

  git = {
    url    = "https://github.com/Logik-Dev/k8s-homelab.git"
    branch = "dev"
    http = {
      username = "flux"
      password = provider::sops::file("${path.module}/secrets.yaml").data.github-token
    }
  }
}
