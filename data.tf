data "aws_region" "current" {}

data "aws_region" "secondary" {
  name = var.aws_region_secondary
}

data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "elb_sa" {}

data "template_file" "userdata" {
  template = file("${path.module}/templates/userdata.sh")

  vars = {
    account_id                = data.aws_caller_identity.current.account_id
    name_prefix               = var.name_prefix
    region                    = data.aws_region.current.name
    vault_cert_dir            = var.vault_cert_dir
    vault_config_dir          = var.vault_config_dir
    vault_additional_userdata = var.vault_additional_userdata
    vault_kms_seal_key_id     = aws_kms_key.seal.key_id
    dynamodb_table_name       = module.dynamodb_table.dynamodb_table_id
    vault_cert_dir            = var.vault_cert_dir
    vault_dns_address         = var.vault_dns_address
    vault_additional_config   = var.vault_additional_config
  }
}
