variable "pool" {
  description = "Libvirt pool where images are stored"
  type        = string
}

variable "extensions" {
  type = list(string)
}
