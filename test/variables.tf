variable "dns_zone" {
  default = "Z2J3KVPABDNIL1"
}

variable "vault_addr" {
  description = "Vault server URL address"
}

variable "bootstrap_version" {
  default = "bump-dataog-agent"
}

variable "domain_sfx" {
  default = ".ops.aeternity.com"
}

variable "envid" {
  description = "Unique test environment identifier to prevent collisions."
}
