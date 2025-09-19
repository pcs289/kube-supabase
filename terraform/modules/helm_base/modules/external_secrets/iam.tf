resource "aws_iam_role" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets"
  description = "IAM role for the external-secrets service account inside the cluster"

  assume_role_policy = data.aws_iam_policy_document.assume_external_secrets.json

  tags = {
    Name        = "${var.cluster_name}-external-secrets"
    Environment = var.environment
  }
}

resource "aws_eks_pod_identity_association" "external_secrets" {
  cluster_name    = var.cluster_name
  service_account = var.service_account
  namespace       = var.namespace
  role_arn        = aws_iam_role.external_secrets.arn
}
