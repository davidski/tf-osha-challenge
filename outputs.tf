output "redshift_password" {
  value = var.redshift_passwor
}

output "redshift_user" {
  value = "mcp"
}

output "cognito_identity_pool" {
  value = aws_cognito_identity_pool.main.id
}
