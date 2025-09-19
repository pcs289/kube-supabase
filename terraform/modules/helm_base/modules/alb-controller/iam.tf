resource "aws_iam_role" "this" {
  name        = "${var.cluster_name}-alb-controller"
  description = "IAM role for the alb-controller service account inside the cluster"

  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = {
    Name        = "${var.cluster_name}-alb-controller"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_policy" "this" {
  name = "${var.cluster_name}-alb-controller"

  policy = file("${path.module}/assets/policy.json")
}

# resource "aws_eks_pod_identity_association" "this" {
#   cluster_name    = var.cluster_name
#   service_account = "alb-controller"
#   namespace       = "alb-controller"
#   role_arn        = aws_iam_role.this.arn
# }
