module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 1"

  name           = var.name_prefix
  hash_key       = "Path"
  range_key      = "Key"
  stream_enabled = true

  attributes = [
    {
      name = "Path"
      type = "S"
    },
    {
      name = "Key"
      type = "S"
    }
  ]

  replica_regions = [
    {
      region_name = var.aws_region_secondary
    }
  ]

  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true

  tags = var.tags
}
