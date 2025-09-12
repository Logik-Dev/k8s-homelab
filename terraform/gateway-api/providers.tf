terraform {
  required_version = ">=1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
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
