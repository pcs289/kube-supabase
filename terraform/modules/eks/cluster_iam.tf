###############################################################################
# IAM role for EKS Control Plane nodes
###############################################################################

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-control-plane-role"
  assume_role_policy = data.aws_iam_policy_document.assume_eks.json
}

// Allow EKS service to assume EKSClusterRole
data "aws_iam_policy_document" "assume_eks" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "aws_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

// Provide AmazonEKSServicePolicy to EKSClusterRole
resource "aws_iam_role_policy_attachment" "aws_eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "aws_eks_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy" "aws_eks_kms_policy" {
  role = aws_iam_role.eks_cluster.name

  name = "${var.cluster_name}-kms-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Resource = aws_kms_key.eks.arn
      }
    ]
  })
}

resource "aws_kms_key" "eks" {
  description             = "KMS key for encrypting secrets in IaC"
  deletion_window_in_days = 30   # A longer window for recovery.
  enable_key_rotation     = true # Crucial for security best practices.

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.eks_cluster.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks/${var.cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}
