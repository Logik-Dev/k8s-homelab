variable "env" {
  type = string
}
variable "libvirt_uri" {
  type = string
}

variable "pools" {
  type = map(string)
}

variable "image_pool" {
  type    = string
  default = "local-pool"
}

variable "nat_networks" {
  type = map(object({
    subnets = list(string)
  }))
  default = {}
}

variable "cluster_endpoint" {
  type = string
}

variable "common_patches" {
  type    = list(string)
  default = ["install", "cni", "metrics-server", "kubelet-certificates-rotation"]
}

variable "instances" {
  type = map(object({
    type       = string
    cpus       = number
    memory     = string
    patches    = list(string)
    extensions = list(string)
    networks = map(object({
      ipv4 = string
    }))
    volumes = map(object({
      size = number
      pool = string
    }))
  }))
}

variable "gateway_api_crds" {
  type = list(string)
  default = [
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]
}
