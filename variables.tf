variable "dns_zone" {}
variable "api_domain" {}
variable "api_aliases" {
  type    = "list"
  default = []
}
variable "lb_fqdn" {}
variable "certificate_arn" {}
variable "env" {}
variable "mdw_fqdn" {}
variable "headers" {
  default = []
}
variable "price_class" {
  default = "PriceClass_All"
}
variable "api_cache_default_ttl" {
  default = 0
}
variable "mdw_cache_default_ttl" {
  default = 0
}
variable "ch_fqdn" {}
