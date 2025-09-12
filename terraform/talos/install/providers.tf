terraform {
  required_version = ">=1.0"
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    sops = {
      source  = "nobbs/sops"
      version = "0.3.0"
    }

  }
}
