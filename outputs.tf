output "secrets" {
  value = module.secrets.secrets
}

output "dynamodb" {
  value = try(aws_dynamodb_table.dynamodb_table[0], null)
}

output "vault_pki" {
  value = {
    ca           = module.pki.ca
    certificates = module.pki.certificates
  }
  sensitive = true
}

output "primary" {
  value = module.primary
}

output "secondary" {
  value = module.primary
}

output "vault_dns_domain" {
  value = var.vault_dns_domain
}
