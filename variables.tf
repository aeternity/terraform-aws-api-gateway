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
variable "error_caching_min_ttl" {
  default = 0
}
variable "error_code" {
  default = 404
}
variable "response_code" {
  default = 0
}
