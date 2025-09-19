locals {

  region              = data.aws_region.current.name
  oidc_provider       = replace(var.oidc_provider_arn, "/^(.*provider/)/", "")
  karpenter_sa        = "karpenter"
  karpenter_namespace = "karpenter"
  karpenter_version   = "1.7.0"
  karpenter_pods      = "1"
  queue_name          = "${var.cluster_name}-karpenter"

}


#############################
#### Helm Chart Karpenter
#############################

resource "helm_release" "karpenter" {
  create_namespace    = true
  namespace           = local.karpenter_namespace
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.this.user_name
  repository_password = data.aws_ecrpublic_authorization_token.this.password
  chart               = "karpenter"
  version             = local.karpenter_version
  wait                = false
  recreate_pods       = true
  skip_crds           = true

  values = [
    templatefile("${path.module}/assets/karpenter_values.yaml", {
      replicas         = local.karpenter_pods
      cluster_endpoint = var.cluster_endpoint
      cluster_name     = var.cluster_name
      cluster_region   = local.region
      role_arn         = var.irsa_role_arn
      queue_name       = local.queue_name
      sa_name          = local.karpenter_sa
    })
  ]

  # Ignored to prevent redeployment
  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}


resource "helm_release" "karpenter_crd" {
  create_namespace    = true
  namespace           = local.karpenter_namespace
  name                = "karpenter-crd"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.this.user_name
  repository_password = data.aws_ecrpublic_authorization_token.this.password
  chart               = "karpenter-crd"
  version             = local.karpenter_version

  # Ignored to prevent redeployment
  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = templatefile("${path.module}/assets/karpenter_class.yaml", {
    node_iam_role = var.worker_role_arn
    cluster_name  = var.cluster_name
  })

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = file("${path.module}/assets/karpenter_pool.yaml")

  depends_on = [
    helm_release.karpenter
  ]
}
