terraform {
  required_version = ">=1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
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

