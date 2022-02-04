output "secrets" {
  value = module.secrets.secrets
}

output "dynamodb" {
  value = module.dynamodb_table
}

output "asg_security_group_id" {
  value = module.sg_vault.security_group_id
}
