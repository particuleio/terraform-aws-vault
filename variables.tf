# The MIT License (MIT)
# Copyright (c) 2014-2021 Avant, Sean Lingren

############################
## Environment #############
############################

variable "aws_region_secondary" {}

variable "name_prefix" {
  type        = string
  description = "A name to prefix every created resource with"
}


variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources"
  default     = {}
}


#############################
### EC2 ##############
#############################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use"
}

variable "asg_desired_capacity" {
  type    = number
  default = 3
}

variable "asg_min_size" {
  type    = number
  default = 3
}

variable "asg_max_size" {
  type    = number
  default = 3
}

variable "asg_key_name" {
  default = null
}

variable "asg_vpc_zone_identifier" {
  type = list(any)
}

variable "asg_disk_size" {
  type    = number
  default = 20
}

variable "asg_tags" {
  type    = list(any)
  default = []
}

variable "asg_tags_as_map" {
  type    = map(string)
  default = {}
}

variable "asg_instance_type" {
  default = "t3a.micro"
}

variable "asg_ami_id" {
  default = "ami-073642a01018de26c"
}

#############################
### Networking ##############
#############################
variable "vault_dns_address" {
  type        = string
  description = "The DNS address that vault will be accessible at"
}

#variable "alb_subnets" {
#  type        = list(string)
#  description = "A list of subnets to launch the ALB in"
#}
#
#variable "ec2_subnets" {
#  type        = list(string)
#  description = "A list of subnets to launch the EC2 instances in"
#}
#
#############################
### EC2 #####################
#############################
#variable "ami_id" {
#  type        = string
#  description = "The ID of the AMI to use to launch Vault"
#}
#
#variable "instance_type" {
#  type        = string
#  description = "The type of instance to launch vault on"
#}
#
#variable "ssh_key_name" {
#  type        = string
#  description = "The name of the ssh key to use for the EC2 instance"
#}
#
#variable "asg_min_size" {
#  type        = string
#  description = "Minimum number of instances in the ASG"
#}
#
#variable "asg_max_size" {
#  type        = string
#  description = "Maximum number of instances in the ASG"
#}
#
#variable "asg_desired_capacity" {
#  type        = string
#  description = "Desired number of instances in the ASG"
#}
#
#############################
### OS ######################
#############################

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

variable "vault_tls_key_pem" {
  default = ""
}

variable "vault_tls_cert_pem" {
  default = ""
}

variable "vault_tls_client_ca_pem" {
  default = ""
}


#############################
### DynamoDB ################
#############################
#variable "dynamodb_table_name" {
#  type        = string
#  description = "The name of the dynamodb table that vault will create to coordinate HA"
#}
#
############################
### DNS #####################
#############################
#variable "route53_enabled" {
#  type        = string
#  description = "Creates Route53 DNS entries for Vault automatically"
#  default     = false
#}
#
#variable "zone_id" {
#  type        = string
#  description = "Zone ID for domain"
#}
#
#variable "secrets" {
#  type    = any
#  default = {}
#}
