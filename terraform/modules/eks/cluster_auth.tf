locals {
  access_entries = {
    eks_nodes = {
      rolearn = aws_iam_role.eks_nodes.arn
      type    = "EC2_LINUX"
    }
    karpenter_node = {
      rolearn = aws_iam_role.karpenter_node.arn
      type    = "EC2_LINUX"
    }
  }
}

resource "aws_eks_access_entry" "this" {
  for_each = local.access_entries

  cluster_name  = aws_eks_cluster.main.name
  principal_arn = each.value.rolearn
  type          = each.value.type
}
