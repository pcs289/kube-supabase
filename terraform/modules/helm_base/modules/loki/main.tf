locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  version         = "6.40.0"
  service_account = "loki"
  namespace       = "monitoring"
}

resource "helm_release" "this" {
  name             = local.service_account
  repository       = "https://grafana.github.io/helm-charts"
  chart            = local.service_account
  version          = local.version
  namespace        = local.namespace
  create_namespace = true
  verify           = false

  values = [
    templatefile("${path.module}/assets/values.yaml", {
      service_account = local.service_account
      namespace       = local.namespace
    })
  ]
}
