module "sg_vault" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  name    = var.name_prefix
  vpc_id  = var.vpc_id

  ingress_with_self = [
    {
      description = "Vault Cluster"
      from_port   = 8201
      to_port     = 8201
      protocol    = "tcp"
      self        = true
    },
  ]
  ingress_with_cidr_blocks = [
    {
      description = "Vault API"
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  ingress_with_ipv6_cidr_blocks = [
    {
      description      = "Vault API"
      from_port        = 8200
      to_port          = 8200
      protocol         = "tcp"
      ipv6_cidr_blocks = "::/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_ipv6_cidr_blocks = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      ipv6_cidr_blocks = "::/0"
    },
  ]

}
