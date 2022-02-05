output "secrets" {
  value = module.secrets.secrets
}

output "dynamodb" {
  value = aws_dynamodb_table.dynamodb_table
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
