data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_instance_profile" "vault" {
  name = var.name_prefix
  role = aws_iam_role.vault.name
}

resource "aws_iam_role" "vault" {
  name               = var.name_prefix
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}

resource "aws_iam_policy" "vault" {
  name   = var.name_prefix
  policy = data.aws_iam_policy_document.vault.json
}

resource "aws_iam_role_policy_attachment" "vault" {
  role       = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.vault.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.vault.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "vault" {

  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable",
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.dynamodb_table.id}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.dynamodb_table.id}/*",
      "arn:aws:dynamodb:${data.aws_region.secondary.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.dynamodb_table.id}",
      "arn:aws:dynamodb:${data.aws_region.secondary.name}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.dynamodb_table.id}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      aws_kms_key.seal.arn,
      aws_kms_replica_key.seal.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = concat(
      [for k, v in module.secrets.secrets : "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${lookup(v, "name", k)}*"],
      [for k, v in module.secrets.secrets : "arn:aws:secretsmanager:${data.aws_region.secondary.name}:${data.aws_caller_identity.current.account_id}:secret:${lookup(v, "name", k)}*"]
    )
  }
}
