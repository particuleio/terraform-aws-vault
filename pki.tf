module "pki" {
  source       = "particuleio/pki/tls"
  version      = "~> 1.0"
  certificates = var.vault_pki_client_certs
}
