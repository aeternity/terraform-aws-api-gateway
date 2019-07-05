variable "dns_zone" {}

variable "loadbalancers" {
  type = "list"
}

variable "loadbalancers_zones" {
  type = "list"
}

variable "loadbalancers_regions" {
  type = "list"
}

variable "api_dns" {}

variable "api_alias" {
  default = ""
}

variable "api_aliases" {
  type    = "list"
  default = []
}

variable "certificate_arn" {}
variable "env" {}
