variable "disks" {
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
  type    = list(string)
  default = []
}

variable "networks" {
  type = map(object({
    ipv4 = string
  }))
  default = {}
}
