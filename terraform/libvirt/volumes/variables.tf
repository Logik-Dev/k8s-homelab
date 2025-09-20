variable "volumes" {
  type = map(object({
    size = number
    pool = string
  }))
}

variable "volumes_prefix" {
  type = string
}

variable "pools" {
  type = map(object({
    name = string
  }))
}
