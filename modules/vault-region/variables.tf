variable "asg" {
  type = any
}

variable "cfssl_version" {
  default = "1.6.1"
}

variable "dynamodb_table_name" {}

variable "iam_instance_profile_arn" {}

variable "name_prefix" {
  default = "vault-"
}

variable "nlbs" {
  type    = any
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources"
  default     = {}
}

variable "vault_version" {
  default = "1.12.2"
}

variable "vault_cert_dir" {
  type        = string
  description = "The directory on the OS to store Vault certificates"
  default     = "/usr/local/etc/vault/tls"
}

variable "vault_config_dir" {
  type        = string
  description = "The directory on the OS to store the Vault configuration"
  default     = "/usr/local/etc/vault"
}

variable "vault_additional_config" {
  type        = string
  description = "Additional content to include in the vault configuration file"
  default     = ""
}

variable "vault_additional_userdata" {
  type        = string
  description = "Additional content to include in the cloud-init userdata for the EC2 instances"
  default     = ""
}

variable "vault_dns_domain" {
  type        = string
  description = "The DNS address that vault will be accessible at"
}

variable "vault_api_address" {
  type        = string
  description = "The address that vault will be accessible at"
}

variable "vault_kms_seal_key_id" {}

variable "vault_routing_policy" {
  default = "all"
  validation {
    condition     = contains(["leader_only", "all"], var.vault_routing_policy)
    error_message = "Values can only be \"leader_only\" or \"all\"."
  }
}

variable "vault_tls_require_and_verify_client_cert" {
  default = false
}

variable "vault_max_lease_ttl" {
  default = "192h"
  type    = string
}

variable "vault_default_lease_ttl" {
  default = "192h"
  type    = string
}

variable "vault_prometheus_retention_time" {
  default = "6h"
  type    = string
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use"
}
