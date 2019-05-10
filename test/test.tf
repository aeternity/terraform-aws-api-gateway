variable "dns_zone" {
  default = "Z2J3KVPABDNIL1"
}

provider "aws" {
  version                 = "1.55"
  region                  = "ap-southeast-2"
  alias                   = "ap-southeast-2"
  shared_credentials_file = "/aws/credentials"
  profile                 = "aeternity"
}

variable "vault_addr" {
  description = "Vault server URL address"
}

variable "bootstrap_version" {
  default = "v2.0.1"
}

variable "test_gateway_dns" {
  default = "api.test.ops.aeternity.com"
}

variable "envid" {
  description = "Unique test environment identifier to prevent collisions."
}

module "aws_deploy-test-gw" {
  source            = "github.com/aeternity/terraform-aws-aenode-deploy?ref=v1.0.0"
  env               = "api_test"
  envid             = "${var.envid}"
  bootstrap_version = "${var.bootstrap_version}"
  vault_role        = "ae-node"
  vault_addr        = "${var.vault_addr}"

  static_nodes      = 0
  spot_nodes        = 0
  gateway_nodes_min = 1
  gateway_nodes_max = 1
  dns_zone          = "${var.dns_zone}"
  gateway_dns       = "origin-${var.test_gateway_dns}"
  spot_price        = "0.15"
  instance_type     = "t3.large"
  ami_name          = "aeternity-ubuntu-16.04-v1549009934"
  root_volume_size  = 8

  additional_storage      = 1
  additional_storage_size = 30

  aeternity = {
    package = "https://releases.ops.aeternity.com/aeternity-2.3.0-ubuntu-x86_64.tar.gz"
  }

  providers = {
    aws = "aws.ap-southeast-2"
  }
}

module "aws_gateway" {
  providers = {
    aws = "aws.ap-southeast-2"
  }

  source   = "../"
  dns_zone = "${var.dns_zone}"

  loadbalancers = [ "${module.aws_deploy-test-gw.gateway_lb_dns}" ]

  loadbalancers_zones = [ "${module.aws_deploy-test-gw.gateway_lb_zone_id}" ]

  loadbalancers_regions = [ "ap-southeast-2" ]

  api_dns   = "${var.test_gateway_dns}"
  api_alias = "${var.test_gateway_dns}"
}
