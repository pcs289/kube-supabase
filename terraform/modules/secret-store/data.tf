data "aws_caller_identity" "this" {}
data "aws_region" "this" {}
data "aws_partition" "this" {}

data "aws_kms_secrets" "this" {
  for_each = var.secrets
  secret {
    name    = each.key
    payload = each.value
  }
}

data "aws_iam_policy_document" "assume" {

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "AWS"
      identifiers = [var.external_secret_role]
    }
  }

}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.environment}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "*"
    ]
  }
}
