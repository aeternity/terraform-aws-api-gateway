variable "dns_zone" {
  default = "Z2J3KVPABDNIL1"
}

# Default provider
provider "aws" {
  version = "2.16.0"
  region  = "us-east-1"
}

provider "aws" {
  version = "2.16.0"
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

variable "vault_addr" {
  description = "Vault server URL address"
}

variable "bootstrap_version" {
  default = "master"
}

variable "domain_sfx" {
  default = ".ops.aeternity.com"
}

variable "envid" {
  description = "Unique test environment identifier to prevent collisions."
}

variable "env_domain" {
  default = "test-tf-gateway"
}

variable "package" {
  default = "https://s3.eu-central-1.amazonaws.com/aeternity-node-builds/aeternity-latest-ubuntu-x86_64.tar.gz"
}

locals {
  api_dns     = "${substr(var.env_domain, 0, 15)}${var.domain_sfx}"
  api_alias   = "${substr(var.env_domain, 0, 15)}${var.domain_sfx}"
  api_aliases = ["${substr(var.env_domain, 0, 15)}-2nd${var.domain_sfx}"]
}

resource "aws_acm_certificate" "cert" {
  domain_name               = "${local.api_dns}"
  subject_alternative_names = "${concat(local.api_aliases, list(local.api_alias))}"
  validation_method         = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  zone_id = "${var.dns_zone}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_route53_record" "cert_validation_alt1" {
  zone_id = "${var.dns_zone}"
  name    = "${aws_acm_certificate.cert.domain_validation_options.1.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.1.resource_record_type}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.1.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = "${aws_acm_certificate.cert.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.cert_validation_alt1.fqdn}",
    "${aws_route53_record.cert_validation.fqdn}",
  ]
}

module "aws_deploy-test-gw" {
  source            = "github.com/aeternity/terraform-aws-aenode-deploy"
  env               = "test"
  envid             = "${var.envid}"
  bootstrap_version = "${var.bootstrap_version}"
  vault_role        = "ae-node"
  vault_addr        = "${var.vault_addr}"

  static_nodes      = 0
  spot_nodes        = 2
  gateway_nodes_min = 1
  gateway_nodes_max = 1
  dns_zone          = "${var.dns_zone}"
  gateway_dns       = "origin-${lenght(substr(var.env_domain, 0, 15))}${var.domain_sfx}"
  spot_price        = "0.15"
  instance_type     = "t3.large"
  ami_name          = "aeternity-ubuntu-16.04-*"

  additional_storage      = 1
  additional_storage_size = 5

  aeternity = {
    package = "${var.package}"
  }

  providers = {
    aws = "aws.ap-southeast-2"
  }
}

module "aws_test_gateway" {
  source   = "../"
  dns_zone = "${var.dns_zone}"

  loadbalancers         = ["${module.aws_deploy-test-gw.gateway_lb_dns}"]
  loadbalancers_zones   = ["${module.aws_deploy-test-gw.gateway_lb_zone_id}"]
  loadbalancers_regions = ["ap-southeast-2"]

  api_dns     = "${local.api_dns}"
  api_alias   = "${local.api_alias}"
  api_aliases = "${local.api_aliases}"

  certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"
}
