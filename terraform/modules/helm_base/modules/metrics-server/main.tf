resource "helm_release" "this" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server"
  chart            = "metrics-server"
  version          = "3.13.0"
  namespace        = var.namespace
  create_namespace = true
  verify           = false

}
