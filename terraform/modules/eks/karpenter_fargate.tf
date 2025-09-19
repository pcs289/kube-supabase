data "aws_iam_policy_document" "assume_karpenter_fargate" {
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

resource "aws_iam_role" "karpenter_fargate" {
  name                  = "${var.cluster_name}-karpenter-fargate"
  assume_role_policy    = data.aws_iam_policy_document.assume_karpenter_fargate.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "karpenter_fargate_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_fargate.name
}

resource "aws_iam_role_policy_attachment" "karpenter_fargate_pod" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.karpenter_fargate.name
}
