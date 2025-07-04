resource "aws_dynamodb_table" "dynamodb_table" {
  count = can(var.existing_dynamodb_tables.primary.name) ? 0 : 1
  name  = var.name_prefix

  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  hash_key  = "Path"
  range_key = "Key"

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  replica {
    region_name            = data.aws_region.secondary.region
    point_in_time_recovery = true
    propagate_tags         = true
  }

  tags = var.tags

}
