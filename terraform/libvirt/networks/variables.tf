variable "nat_networks" {
  type = map(object({
    subnets = list(string)
  }))
  default = {}
}
