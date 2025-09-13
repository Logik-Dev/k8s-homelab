variable "env" {
  type = string
}

variable "libvirt_uri" {
  type    = string
  default = "qemu+ssh://logikdev@192.168.10.100/system"
}

variable "pools" {
  type = map(string)
}

variable "image_pool" {
  type    = string
  default = "local"
}

variable "cluster_endpoint" {
  type = string
}

variable "common_patches" {
  type    = list(string)
  default = ["install", "metrics-server", "kubelet-certificates-rotation", "raw-volumes", "interfaces"]
}

variable "cilium_enabled" {
  type    = bool
  default = false
}

variable "instances" {
  type = map(object({
    type       = string
    cpus       = number
    memory     = string
    ip         = string
    patches    = list(string)
    extensions = list(string)
    bridges    = map(string)
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
