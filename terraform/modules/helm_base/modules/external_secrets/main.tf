locals {
  account_id    = data.aws_caller_identity.current.account_id
  partition     = data.aws_partition.current.partition
  region        = data.aws_region.current.name
  oidc_provider = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.19.2"
  namespace        = var.namespace
  create_namespace = true
  verify           = false

  values = [
    templatefile("${path.module}/assets/values.yaml", {
      role_arn        = aws_iam_role.external_secrets.arn
      service_account = var.service_account
      namespace       = var.namespace
    })
  ]
}
