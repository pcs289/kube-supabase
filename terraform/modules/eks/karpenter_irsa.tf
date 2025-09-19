locals {
  oidc_provider       = replace(aws_iam_openid_connect_provider.main.arn, "/^(.*provider/)/", "")
  karpenter_sa        = "karpenter"
  karpenter_namespace = "karpenter"

}
data "aws_iam_policy_document" "assume_karpenter_irsa" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.main.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:${local.karpenter_namespace}:${local.karpenter_sa}"]
    }

    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "karpenter_irsa" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateTags"
    ]
    resources = [
      "arn:${local.partition}:ec2:${local.region}::image/*",
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.karpenter_node.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:${local.partition}:ssm:${local.region}::parameter/aws/service/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:TerminateInstances"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.this.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:TagInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:ListInstanceProfiles"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "karpenter_irsa" {
  name        = "${var.cluster_name}-karpenter-irsa"
  description = "${var.cluster_name} Karpenter IRSA Policy"
  policy      = data.aws_iam_policy_document.karpenter_irsa.json
}

resource "aws_iam_role_policy_attachment" "karpenter_node_policy" {
  policy_arn = aws_iam_policy.karpenter_irsa.arn
  role       = aws_iam_role.karpenter_irsa.name
}

resource "aws_iam_role" "karpenter_irsa" {
  name                  = "${var.cluster_name}-karpenter-irsa"
  assume_role_policy    = data.aws_iam_policy_document.assume_karpenter_irsa.json
  force_detach_policies = true
}
