locals {

  account_id    = data.aws_caller_identity.current.account_id
  partition     = data.aws_partition.current.partition
  region        = data.aws_region.current.name
  oidc_provider = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")

  version         = "1.13.4"
  replicas        = 1
  name            = "alb-controller"
  service_account = "aws-load-balancer-controller"
  namespace       = "alb-controller"

}

resource "helm_release" "this" {
  name             = local.name
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = local.version
  namespace        = local.namespace
  create_namespace = true
  verify           = false

  values = [
    templatefile("${path.module}/assets/values.yaml", {
      replicas        = local.replicas
      cluster_name    = var.cluster_name
      aws_region      = local.region
      aws_vpc         = var.vpc_id
      service_account = local.service_account
      name            = local.name
      role_arn        = aws_iam_role.this.arn
    })
  ]

}

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  service_account = local.service_account
  namespace       = local.namespace
  role_arn        = aws_iam_role.this.arn
}
