variable "env" {
  type = string
}

variable "talos_version" {
  type    = string
  default = "1.11"
}

variable "instances_ids" {
  type = map(object({
    id = string
  }))
}

variable "cluster_endpoint" {
  type = string
}

variable "cni_disabled" {
  type = bool
}

variable "common_patches" {
  type = list(string)
}

variable "machines" {
  type = map(object({
    type    = string
    patches = list(string)
    ip      = string
  }))
}

variable "installer_urls" {
  type = map(object({
    installer_url = string
  }))
}

variable "kubeconfig_path" {
  type = string
}

variable "talosconfig_path" {
  type = string
}
