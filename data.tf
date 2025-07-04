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

data "aws_dynamodb_table" "existing_dynamodb_table_primary" {
  count = can(var.existing_dynamodb_tables.primary.name) ? 1 : 0
  name  = var.existing_dynamodb_tables.primary.name
}

data "aws_dynamodb_table" "existing_dynamodb_table_secondary" {
  count = can(var.existing_dynamodb_tables.secondary.name) ? 1 : 0
  name  = var.existing_dynamodb_tables.secondary.name
}

data "aws_kms_key" "existing_kms_seal_key_id" {
  count  = var.existing_kms_seal_key_id == "" ? 0 : 1
  key_id = var.existing_kms_seal_key_id
}
