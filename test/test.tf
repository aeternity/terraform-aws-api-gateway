locals {
  api_domain  = format("gw%s%s", var.envid, var.domain_sfx)
  api_aliases = [format("alias%s%s", var.envid, var.domain_sfx)]
  lb_fqdn     = format("lb%s%s", var.envid, var.domain_sfx)
  mdw_fqdn    = "testnet.aeternal.io"
  ae_mdw_fqdn = "mdw.testnet.aeternity.io"
}

module "test_nodes_sydney" {
  source            = "github.com/aeternity/terraform-aws-aenode-deploy?ref=master"
  env               = "test"
  envid             = var.envid
  bootstrap_version = var.bootstrap_version
  vault_role        = "ae-node"
  vault_addr        = var.vault_addr

  static_nodes   = 0
  spot_nodes_min = 1
  spot_nodes_max = 2

  spot_price    = "0.15"
  instance_type = "t3.large"
  ami_name      = "aeternity-ubuntu-18.04-*"

  additional_storage      = true
  additional_storage_size = 5

  asg_target_groups = module.test_lb_sydney.target_groups

  providers = {
    aws = aws.ap-southeast-2
  }
}

module "test_nodes_sydney_channels" {
  source            = "github.com/aeternity/terraform-aws-aenode-deploy?ref=master"
  env               = "test"
  envid             = var.envid
  bootstrap_version = var.bootstrap_version
  vault_role        = "ae-node"
  vault_addr        = var.vault_addr
  subnets           = module.test_nodes_sydney.subnets
  vpc_id            = module.test_nodes_sydney.vpc_id

  enable_state_channels = true

  static_nodes   = 1
  spot_nodes_min = 0
  spot_nodes_max = 0

  spot_price    = "0.15"
  instance_type = "t3.large"
  ami_name      = "aeternity-ubuntu-16.04-*"

  additional_storage      = true
  additional_storage_size = 5

  asg_target_groups = module.test_lb_sydney.target_groups_channels

  providers = {
    aws = aws.ap-southeast-2
  }
}

module "test_lb_sydney" {
  source                    = "github.com/aeternity/terraform-aws-api-loadbalancer?ref=master"
  fqdn                      = local.lb_fqdn
  dns_zone                  = var.dns_zone
  sc_security_group         = module.test_nodes_sydney_channels.sg_id
  security_group            = module.test_nodes_sydney.sg_id
  vpc_id                    = module.test_nodes_sydney.vpc_id
  subnets                   = module.test_nodes_sydney.subnets
  internal_api_enabled      = true
  state_channel_api_enabled = true

  providers = {
    aws = aws.ap-southeast-2
  }
}

module "test_gateway" {
  source          = "../"
  env             = "test"
  dns_zone        = var.dns_zone
  api_domain      = local.api_domain
  api_aliases     = local.api_aliases
  certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  lb_fqdn         = local.lb_fqdn
  mdw_fqdn        = local.mdw_fqdn
  ch_fqdn         = module.test_lb_sydney.dns_name
  ae_mdw_fqdn     = local.ae_mdw_fqdn
  price_class     = "PriceClass_100"
}
