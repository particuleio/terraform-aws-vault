data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "vault" {
  most_recent = true
  name_regex  = "vault-${var.vault_version}-al2022-*"
  owners      = ["886701765425"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "cloudinit_config" "userdata" {

  base64_encode = true
  gzip          = false
  boundary      = "//"

  part {
    content_type = "text/x-shellscript"
    content = templatefile(
      "${path.module}/templates/userdata.sh",
      {
        account_id                               = data.aws_caller_identity.current.account_id
        name_prefix                              = var.name_prefix
        region                                   = data.aws_region.current.name
        vault_cert_dir                           = var.vault_cert_dir
        vault_config_dir                         = var.vault_config_dir
        vault_additional_userdata                = var.vault_additional_userdata
        vault_kms_seal_key_id                    = var.vault_kms_seal_key_id
        dynamodb_table_name                      = var.dynamodb_table_name
        vault_cert_dir                           = var.vault_cert_dir
        vault_api_address                        = var.vault_api_address
        vault_dns_domain                         = var.vault_dns_domain
        vault_additional_config                  = var.vault_additional_config
        vault_tls_require_and_verify_client_cert = var.vault_tls_require_and_verify_client_cert
        cfssl_version                            = var.cfssl_version
        vault_max_lease_ttl                      = var.vault_max_lease_ttl
        vault_default_lease_ttl                  = var.vault_default_lease_ttl
      }
    )
  }
}
