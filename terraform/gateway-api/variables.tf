variable "manifest_urls" {
  description = "URLs of manifests to apply"
  type        = list(string)
}
variable "wait_for_apiserver" {
  type = map(string)
}
variable "kubeconfig" {
  type = object({
    ca_certificate     = string
    client_certificate = string
    client_key         = string
    host               = string
  })
}
