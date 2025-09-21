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
  default = ["install", "metrics-server", "kubelet-certificates-rotation", "user-volumes", "interfaces", "load-balancer", "extra-manifests"]
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

variable "xml" {
  type        = string
  description = "Extra XML"
  default     = null
}
