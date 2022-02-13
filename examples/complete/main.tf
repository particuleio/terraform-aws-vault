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
  version = "3.0"
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
  version = "3.0"
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

################################################################################
# Vault without mutual TLS with all options
################################################################################
module "vault" {
  providers = {
    aws.secondary = aws.secondary
  }
  source      = "../../"
  name_prefix = "vault-complete"

  cfssl_version = "1.6.1"

  asg_defaults = {
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

  nlb_defaults = {
    internal        = false
    listener_port   = 443
    subnets         = []
    ip_address_type = "dualstack"
  }

  vault_dns_domain                         = "vault-complete.particule.tech"
  vault_api_address                        = "https://vault-complete.particule.tech"
  vault_routing_policy                     = "all"
  vault_tls_require_and_verify_client_cert = false

  vault_pki_ca_config = {
    algorithm   = "ECDSA"
    ecdsa_curve = "P384"
    subject = {
      common_name         = "Certificate Authority"
      organization        = "Org"
      organizational_unit = "OU"
      street_address = [
        "Street"
      ]
      locality      = "Locality"
      province      = "Province"
      country       = "Country"
      postal_code   = "Postal Code"
      serial_number = "Serial Number"
    }
    validity_period_hours = 87600
    early_renewal_hours   = 78840
    allowed_uses = [
      "cert_signing",
      "crl_signing",
      "code_signing",
      "server_auth",
      "client_auth",
      "digital_signature",
      "key_encipherment",
    ]
  }

  vault_pki_client_certs = {
    mycert = {
      algorithm   = "ECDSA"
      ecdsa_curve = "P384"
      subject = {
        common_name         = "Certificate Authority"
        organization        = "Org"
        organizational_unit = "OU"
        street_address = [
          "Street"
        ]
        locality      = "Locality"
        province      = "Province"
        country       = "Country"
        postal_code   = "Postal Code"
        serial_number = "Serial Number"
      }
      validity_period_hours = 8740
      early_renewal_hours   = 8040
      dns_names = [
        "mydomain.com"
      ]
      ip_addresses = [
        "10.0.0.1"
      ]
      uris = []
      allowed_uses = [
        "server_auth",
        "client_auth",
      ]
    }
  }

  route53_zone_name         = "particule.tech"
  route53_private_zone_name = ""

  vpc_id              = module.vpc_primary.vpc_id
  vpc_secondary_id    = module.vpc_secondary.vpc_id
  vpc_peering_enabled = false

  asg = {
    vpc_zone_identifier             = module.vpc_primary.private_subnets
    desired_capacity                = 1
    min_size                        = 0
    max_size                        = 3
    key_name                        = null
    disk_size                       = 20
    instance_type                   = "t3a.micro"
    tags_as_map                     = {}
    tags                            = {}
    asg_associate_public_ip_address = false
  }

  asg_secondary = {
    vpc_zone_identifier             = module.vpc_secondary.private_subnets
    desired_capacity                = 1
    min_size                        = 0
    max_size                        = 3
    key_name                        = null
    disk_size                       = 20
    instance_type                   = "t3a.micro"
    tags_as_map                     = {}
    tags                            = {}
    asg_associate_public_ip_address = false
  }

  nlbs = {
    "external" = {
      subnets                          = module.vpc_primary.public_subnets
      enable_cross_zone_load_balancing = true
    }
    "internal" = {
      subnets                          = module.vpc_primary.private_subnets
      internal                         = true
      enable_cross_zone_load_balancing = true
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
