output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.main.arn
}

output "karpenter_roles" {
  value = {
    fargate_role_arn = aws_iam_role.karpenter_fargate.arn
    irsa_role_arn    = aws_iam_role.karpenter_irsa.arn
    worker_role_arn  = aws_iam_role.karpenter_node.arn
  }
}
