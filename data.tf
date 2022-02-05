data "aws_region" "current" {}

data "aws_region" "secondary" {
  provider = aws.secondary
}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "elb_sa" {}

data "aws_vpc" "vpc" {
  count = var.vpc_peering_enabled ? 1 : 0
  id    = var.vpc_id
}

data "aws_route_tables" "vpc" {
  count  = var.vpc_peering_enabled ? 1 : 0
  vpc_id = var.vpc_id
}

data "aws_vpc" "vpc_secondary" {
  count    = var.vpc_peering_enabled ? 1 : 0
  provider = aws.secondary
  id       = var.vpc_secondary_id
}

data "aws_route_tables" "vpc_secondary" {
  count    = var.vpc_peering_enabled ? 1 : 0
  provider = aws.secondary
  vpc_id   = var.vpc_secondary_id
}
