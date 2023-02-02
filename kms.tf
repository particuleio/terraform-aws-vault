resource "aws_kms_alias" "seal" {
  name          = "alias/${var.name_prefix}/seal"
  target_key_id = aws_kms_key.seal.key_id
}

resource "aws_kms_alias" "seal_secondary" {
  provider      = aws.secondary
  name          = "alias/${var.name_prefix}/seal"
  target_key_id = aws_kms_replica_key.seal.key_id
}

resource "aws_kms_key" "seal" {
  description = "KMS key used for ${var.name_prefix} seal"

  enable_key_rotation = true
  multi_region        = true

  tags = merge(
    { "Name" = "${var.name_prefix}-seal" },
    var.tags,
  )
}

resource "aws_kms_replica_key" "seal" {
  provider        = aws.secondary
  description     = "KMS key used for ${var.name_prefix} seal"
  primary_key_arn = aws_kms_key.seal.arn
}

module "kms_dynamodb" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "~> 1.4"
  description = "KMS key used for ${var.name_prefix} DynamoDB"

  aliases = [
    "${var.name_prefix}/dynamodb"
  ]

  tags = merge(
    { "Name" = "${var.name_prefix}-dynamodb" },
    var.tags,
  )
}
