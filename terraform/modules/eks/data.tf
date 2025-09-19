data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_ecrpublic_authorization_token" "this" {}
data "aws_iam_policy_document" "assume_pod_identity" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:${local.ebs_sa}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.main.arn]
      type        = "Federated"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.main.name
}
