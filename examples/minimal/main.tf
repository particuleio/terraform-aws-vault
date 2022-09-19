locals {
  name_prefix        = "vault-demo"
  tags               = {}
  vpc_primary_cidr   = "10.0.0.0/16"
  vpc_secondary_cidr = "10.1.0.0/16"
}

module "vpc_primary" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name_prefix
  cidr = local.vpc_primary_cidr

  azs             = data.aws_availability_zones.primary.names
  public_subnets  = [for k, v in slice(data.aws_availability_zones.primary.names, 0, 3) : cidrsubnet(local.vpc_primary_cidr, 3, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.primary.names, 0, 3) : cidrsubnet(local.vpc_primary_cidr, 3, k + 3)]

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes     = [0, 1, 2]
  private_subnet_ipv6_prefixes    = [3, 4, 5]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_security_group = true

  default_security_group_egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]
  default_security_group_ingress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]

  tags = local.tags
}

module "vpc_endpoints_primary" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.0"
  vpc_id  = module.vpc_primary.vpc_id
  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc_primary.private_route_table_ids, module.vpc_primary.public_route_table_ids])
      tags            = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc_primary.private_route_table_ids, module.vpc_primary.public_route_table_ids])
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      service_type        = "Interface"
      subnet_ids          = flatten([module.vpc_primary.private_subnets])
      security_group_ids  = [module.vpc_primary.default_security_group_id]
      private_dns_enabled = true
      tags                = { Name = "kms-vpc-endpoint" }
    },
  }
  tags = local.tags
}

module "vpc_secondary" {
  providers = {
    aws = aws.secondary
  }
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name_prefix
  cidr = local.vpc_secondary_cidr

  azs             = data.aws_availability_zones.secondary.names
  public_subnets  = [for k, v in slice(data.aws_availability_zones.secondary.names, 0, 3) : cidrsubnet(local.vpc_secondary_cidr, 3, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.secondary.names, 0, 3) : cidrsubnet(local.vpc_secondary_cidr, 3, k + 3)]

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes     = [0, 1, 2]
  private_subnet_ipv6_prefixes    = [3, 4, 5]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_security_group = true

  default_security_group_egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]
  default_security_group_ingress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = "0.0.0.0/0"
      ipv6_cidr_blocks = "::/0"
    }
  ]

  tags = local.tags
}

module "vpc_endpoints_secondary" {
  providers = {
    aws = aws.secondary
  }
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.0"
  vpc_id  = module.vpc_secondary.vpc_id
  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc_secondary.private_route_table_ids, module.vpc_secondary.public_route_table_ids])
      tags            = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc_secondary.private_route_table_ids, module.vpc_secondary.public_route_table_ids])
      tags            = { Name = "dynamodb-vpc-endpoint" }
    },
    kms = {
      service             = "kms"
      service_type        = "Interface"
      subnet_ids          = flatten([module.vpc_secondary.private_subnets])
      security_group_ids  = [module.vpc_secondary.default_security_group_id]
      private_dns_enabled = true
      tags                = { Name = "kms-vpc-endpoint" }
    },
  }
  tags = local.tags
}


#
# Vault with mutual TLS and minimum options
#
module "vault" {
  providers = {
    aws.secondary = aws.secondary
  }
  source      = "../../"
  name_prefix = "vault-demo"

  vault_dns_domain                         = "vault-demo.particule.tech"
  vault_api_address                        = "https://vault-demo.particule.tech"
  vault_routing_policy                     = "all"
  vault_tls_require_and_verify_client_cert = false

  route53_zone_name         = "particule.tech"
  route53_private_zone_name = ""

  vpc_id              = module.vpc_primary.vpc_id
  vpc_secondary_id    = module.vpc_secondary.vpc_id
  vpc_peering_enabled = true


  asg = {
    vpc_zone_identifier = module.vpc_primary.private_subnets
  }

  asg_secondary = {
    vpc_zone_identifier = module.vpc_secondary.private_subnets
    desired_capacity    = 1
  }

  nlbs = {
    "external" = {
      subnets = module.vpc_primary.public_subnets
    }
    "internal" = {
      subnets  = module.vpc_primary.private_subnets
      internal = true
    }
  }

  nlbs_secondary = {
    "external" = {
      subnets = module.vpc_secondary.public_subnets
    }
    "internal" = {
      subnets  = module.vpc_secondary.public_subnets
      internal = true
    }
  }
}

output "vpc_primary" {
  value = module.vpc_primary
}

output "vpc_endpoints_primary" {
  value = module.vpc_primary
}

output "vpc_secondary" {
  value = module.vpc_primary
}

output "vpc_endpoints_secondary" {
  value = module.vpc_primary
}

output "vault" {
  value     = module.vault
  sensitive = true
}
