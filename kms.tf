resource "aws_kms_alias" "seal" {
  count         = var.existing_kms_seal_key_id == "" ? 1 : 0
  name          = "alias/${var.name_prefix}/seal"
  target_key_id = aws_kms_key.seal[0].key_id
}

resource "aws_kms_alias" "seal_secondary" {
  count         = var.existing_kms_seal_key_id == "" ? 1 : 0
  provider      = aws.secondary
  name          = "alias/${var.name_prefix}/seal"
  target_key_id = aws_kms_replica_key.seal[0].key_id
}

resource "aws_kms_key" "seal" {
  count       = var.existing_kms_seal_key_id == "" ? 1 : 0
  description = "KMS key used for ${var.name_prefix} seal"

  enable_key_rotation = true
  multi_region        = true

  tags = merge(
    { "Name" = "${var.name_prefix}-seal" },
    var.tags,
  )
}

resource "aws_kms_replica_key" "seal" {
  count           = var.existing_kms_seal_key_id == "" ? 1 : 0
  provider        = aws.secondary
  description     = "KMS key used for ${var.name_prefix} seal"
  primary_key_arn = aws_kms_key.seal[0].arn
}
