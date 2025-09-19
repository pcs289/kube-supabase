output "decrypted_secrets" {
  description = "A map of decrypted secrets."
  value = {
    for k, v in aws_secretsmanager_secret_version.this : k => v.secret_string
  }
  sensitive = true
}
