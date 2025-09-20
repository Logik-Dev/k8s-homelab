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

variable "cluster_ready" {
  type = string
}
