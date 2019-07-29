variable "dns_zone" {
  default = "Z2J3KVPABDNIL1"
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

variable "package" {
  default = "https://s3.eu-central-1.amazonaws.com/aeternity-node-builds/aeternity-latest-ubuntu-x86_64.tar.gz"
}
