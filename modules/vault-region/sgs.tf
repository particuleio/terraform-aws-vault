module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  name    = var.name_prefix
  vpc_id  = var.vpc_id

  ingress_with_self = [
    {
      description = "Vault Cluster"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
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
    {
      description = "NLB Health Checks"
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
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
    {
      description      = "NLB Health Checks"
      from_port        = 9200
      to_port          = 9200
      protocol         = "tcp"
      ipv6_cidr_blocks = data.aws_vpc.vpc.ipv6_cidr_block
    },
  ]
  egress_with_cidr_blocks = [
    for _, cidr in var.sg_egress_ipv4_cidrs : {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = cidr
    }
  ]
  egress_with_ipv6_cidr_blocks = [
    for _, cidr in var.sg_egress_ipv6_cidrs : {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      ipv6_cidr_blocks = cidr
    }
  ]
  # DynamoDB gateway endpoint (storage backend) routes to public IPs, not covered by the CIDR rules
  egress_with_prefix_list_ids = [
    {
      description     = "DynamoDB"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      prefix_list_ids = data.aws_prefix_list.dynamodb.id
    },
  ]

}
