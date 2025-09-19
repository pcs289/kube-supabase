data "aws_caller_identity" "current" {}
data "aws_availability_zones" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_ecrpublic_authorization_token" "this" {}
data "aws_iam_policy_document" "assume_pod_identity" {
  statement {
    sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
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
}
