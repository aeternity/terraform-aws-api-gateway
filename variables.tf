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
