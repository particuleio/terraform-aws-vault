module "pki" {
  source       = "particuleio/pki/tls"
  version      = "~> 2.0"
  certificates = var.vault_pki_client_certs
  ca           = var.vault_pki_ca_config
}
