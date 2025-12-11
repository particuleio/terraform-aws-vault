# The MIT License (MIT)
# Copyright (c) 2014-2021 Avant, Sean Lingren

############################
## Global ##################
############################

variable "name_prefix" {
  type        = string
  description = "A name to prefix every created resource with"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources"
  default     = {}
}

variable "ami_owners" {
  type = list(string)
  default = [
    "886701765425",
  ]
}

variable "ami_name_regex" {
  type    = string
  default = null
}

variable "cfssl_version" {
  default = "1.6.4"
}

variable "vpc_peering_enabled" {
  default = true
}

variable "asg_defaults" {
  type = any
  default = {
    desired_capacity                = 3
    min_size                        = 0
    max_size                        = 3
    key_name                        = null
    disk_size                       = 20
    instance_type                   = "t3a.micro"
    vpc_zone_identifier             = []
    tags_as_map                     = {}
    tags                            = {}
    asg_associate_public_ip_address = false
  }
}

variable "nlb_defaults" {
  type = any
  default = {
    internal        = false
    listener_port   = 443
    subnets         = []
    ip_address_type = "dualstack"
  }
}

variable "vault_api_address" {
  type        = string
  description = "The address that vault will be accessible at"
}

variable "vault_dns_domain" {
  type        = string
  description = "The DNS address that vault will be accessible at"
}

variable "vault_pki_ca_config" {
  type    = any
  default = {}
}

variable "vault_pki_client_certs" {
  type = any
  default = {
    "default" = {
      usages = [
        "client_auth",
        "key_encipherement",
        "digital_signature",
      ]
      subject = {
        common_name = "default-vault-client"

      }
    }
  }
}

variable "vault_version" {
  default = "1.14.2"
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

variable "vault_tls_min_version" {
  default = "tls12"
  type    = string
}

#############################
### VPC #####################
#############################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use"
}

variable "vpc_secondary_id" {
  type        = string
  description = "The ID of the VPC to use"
}

#############################
### EC2 #####################
#############################

variable "asg" {
  type = any
}

variable "asg_secondary" {
  type = any
}

#############################
### NLB #####################
#############################

variable "nlbs" {
  type = any
  default = {
    "external" = {
    }
    "internal" = {
      internal = true
    }
  }
}

variable "nlbs_secondary" {
  type = any
  default = {
    "external" = {
    }
    "internal" = {
      internal = true
    }
  }
}

#############################
### DNS #####################
#############################

variable "route53_zone_name" {
  default = ""
}

variable "route53_private_zone_name" {
  default = ""
}

variable "existing_dynamodb_tables" {
  default = {}
  type = object({
    primary = optional(object({
      name = string
    }))
    secondary = optional(object({
      name = string
    }))
  })
  description = "use exising dynamodbs tables (useful for recovery)"
}

variable "existing_kms_seal_key_id" {
  default     = ""
  description = "use existing kms unseal key (useful for recovery)"
}
