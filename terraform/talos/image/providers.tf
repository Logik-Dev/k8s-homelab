terraform {
  required_version = ">=1.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }

  }
}
