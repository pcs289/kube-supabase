locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  version         = "0.60.1"
  service_account = "victoria-metrics"
  namespace       = "monitoring"
}

resource "helm_release" "this" {
  name             = "vm"
  repository       = "https://victoriametrics.github.io/helm-charts/"
  chart            = "victoria-metrics-k8s-stack"
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
