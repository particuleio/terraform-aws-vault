module "primary" {
  source = "./modules/vault-region"

  name_prefix = var.name_prefix

  vpc_id = var.vpc_id

  asg = local.asg

  nlbs = local.nlbs

  dynamodb_table_name = var.existing_dynamodb_tables == {} ? aws_dynamodb_table.dynamodb_table[0].id : var.existing_dynamodb_tables.primary.name

  iam_instance_profile_arn = aws_iam_instance_profile.vault.arn

  vault_kms_seal_key_id = var.existing_kms_seal_key_id == "" ? aws_kms_key.seal[0].key_id : data.aws_kms_key.existing_kms_seal_key_id[0].id


  ami_owners     = var.ami_owners
  ami_name_regex = var.ami_name_regex

  vault_version                            = var.vault_version
  vault_cert_dir                           = var.vault_cert_dir
  vault_config_dir                         = var.vault_config_dir
  vault_additional_config                  = var.vault_additional_config
  vault_additional_userdata                = var.vault_additional_userdata
  vault_dns_domain                         = var.vault_dns_domain
  vault_api_address                        = var.vault_api_address
  vault_routing_policy                     = var.vault_routing_policy
  vault_tls_require_and_verify_client_cert = var.vault_tls_require_and_verify_client_cert
  vault_max_lease_ttl                      = var.vault_max_lease_ttl
  vault_default_lease_ttl                  = var.vault_default_lease_ttl
  vault_prometheus_retention_time          = var.vault_prometheus_retention_time
  vault_tls_min_version                    = var.vault_tls_min_version

  tags = var.tags
}

module "secondary" {
  providers = {
    aws = aws.secondary
  }
  source = "./modules/vault-region"

  name_prefix = var.name_prefix

  vpc_id = var.vpc_secondary_id

  asg = local.asg_secondary

  nlbs = local.nlbs_secondary

  dynamodb_table_name = var.existing_dynamodb_tables == {} ? aws_dynamodb_table.dynamodb_table[0].id : var.existing_dynamodb_tables.secondary.name

  iam_instance_profile_arn = aws_iam_instance_profile.vault.arn

  vault_kms_seal_key_id = var.existing_kms_seal_key_id == "" ? aws_kms_key.seal[0].key_id : data.aws_kms_key.existing_kms_seal_key_id[0].id

  ami_owners     = var.ami_owners
  ami_name_regex = var.ami_name_regex

  vault_version                            = var.vault_version
  vault_cert_dir                           = var.vault_cert_dir
  vault_config_dir                         = var.vault_config_dir
  vault_additional_config                  = var.vault_additional_config
  vault_additional_userdata                = var.vault_additional_userdata
  vault_dns_domain                         = var.vault_dns_domain
  vault_api_address                        = var.vault_api_address
  vault_routing_policy                     = var.vault_routing_policy
  vault_tls_require_and_verify_client_cert = var.vault_tls_require_and_verify_client_cert
  vault_max_lease_ttl                      = var.vault_max_lease_ttl
  vault_default_lease_ttl                  = var.vault_default_lease_ttl
  vault_prometheus_retention_time          = var.vault_prometheus_retention_time
  vault_tls_min_version                    = var.vault_tls_min_version

  tags = var.tags
}
