module "secrets" {
  source  = "particuleio/secretsmanager/aws"
  version = ">= 1.2"

  secrets = {

    "${var.name_prefix}/tls/ca_pem" = {
      name    = "${var.name_prefix}/tls/ca_pem"
      content = module.pki.ca.cert.cert_pem
      replicas = [
        {
          region = data.aws_region.secondary.name
        }
      ]
      force_overwrite_replica_secret = true
    }

    "${var.name_prefix}/tls/ca_key" = {
      name    = "${var.name_prefix}/tls/ca_key"
      content = module.pki.ca.private_key.private_key_pem
      replicas = [
        {
          region = data.aws_region.secondary.name
        }
      ]
      force_overwrite_replica_secret = true
    }
  }
}
