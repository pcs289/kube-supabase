locals {

  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

}

data "aws_iam_policy_document" "fargate_assume" {
  // Allow FargateRole to be assumed by EC2 Service
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
  // Allow FargateRole to be assumed by EKS Pods Service
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
  // Allow FargateRole to be assumed by EKS Fargate Pods Service
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:${local.partition}:eks:${local.region}:${local.account_id}:fargateprofile/${var.cluster_name}/*",
      ]
    }
  }
}

resource "aws_iam_role" "fargate" {
  name                  = "${var.cluster_name}-fargate-role"
  description           = "Fargate Role for ${var.cluster_name} cluster"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume.json
  force_detach_policies = true
}

// Attach AmazonEKS_CNI_Policy to FargateRole
resource "aws_iam_role_policy_attachment" "fargate_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.fargate.name
}

// Attach AmazonEKSFargatePodExecutionRolePolicy to FargateRole
resource "aws_iam_role_policy_attachment" "fargate_pod" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

########################################################################################
## NOTE: Fargate Profile named `karpenter` uses `KarpenterRole` as PodExecutionRole
# the rest of Fargate Profiles use generic FargateRole as PodExecutionRole
########################################################################################
resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = var.cluster_name
  fargate_profile_name   = each.value.name != null ? each.value.name : each.key
  pod_execution_role_arn = each.key == "karpenter" ? aws_iam_role.karpenter_fargate.arn : aws_iam_role.fargate.arn
  subnet_ids             = var.eks_subnets

  dynamic "selector" {
    for_each = each.value.selectors

    content {
      namespace = selector.value.namespace
      labels    = lookup(selector.value, "labels", {})
    }
  }

  depends_on = [aws_eks_cluster.main]
}
