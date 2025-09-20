variable "volumes" {
  type = map(object({
    id = string
  }))
}

variable "name" {
  type = string
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "cdrom_id" {
  type = string
}

variable "bridges" {
  type    = map(string)
  default = {}
}

variable "networks" {
  type = map(object({
    ipv4 = string
  }))
  default = {}
}

variable "xml" {
  type        = string
  description = "Additional XML configuration for libvirt domain"
  default     = null
}
