locals {
  account_id   = data.aws_caller_identity.this.account_id
  root_account = "arn:aws:iam::${local.account_id}:root"
  partition    = data.aws_partition.this.partition
  region       = data.aws_region.this.name

}

## KMS

resource "aws_kms_key" "this" {
  description             = "KMS key for encrypting secrets in IaC"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRoot"
        Effect = "Allow"
        Principal = {
          AWS = local.root_account
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}-key"
  target_key_id = aws_kms_key.this.key_id
}

## IAM

resource "aws_iam_role" "this" {
  name        = var.name
  description = "IAM role for the ${var.name} SecretStore"

  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_iam_policy" "this" {
  name        = var.name
  description = "${var.name} ExternalSecrets SecretStore Policy"
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

## Secrets

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets
  name     = "${var.environment}-${lower(replace(each.key, "_", "-"))}"
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each      = var.secrets
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = data.aws_kms_secrets.this[each.key].plaintext[each.key]
}
