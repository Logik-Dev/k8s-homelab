variable "env" {
  type = string
}

variable "kubeconfig" {
  type = object({
    ca_certificate     = string
    client_certificate = string
    client_key         = string
    host               = string
  })
}

variable "cilium_deps" {
  type = map(any)
}
