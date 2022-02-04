module "secrets" {
  #source  = "particuleio/secretsmanager/aws"
  #version = "~> 1"
  source = "/home/klefevre/git/particuleio/terraform-aws-secretsmanager"
  secrets = {

    "${var.name_prefix}/tls/ca_pem" = {
      content = var.vault_tls_client_ca_pem
      replicas = [
        {
          region = var.aws_region_secondary
        }
      ]
    }

    "${var.name_prefix}/tls/cert_pem" = {
      content = var.vault_tls_cert_pem
      replicas = [
        {
          region = var.aws_region_secondary
        }
      ]
    }

    "${var.name_prefix}/tls/key_pem" = {
      content = var.vault_tls_key_pem
      replicas = [
        {
          region = var.aws_region_secondary
        }
      ]
    }
  }
}
