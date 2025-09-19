data "aws_iam_policy_document" "assume_karpenter_node" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_node" {
  name                  = "${var.cluster_name}-karpenter-node"
  assume_role_policy    = data.aws_iam_policy_document.assume_karpenter_node.json
  force_detach_policies = true
}

// Attach AmazonEKSWorkerNodePolicy to KarpenterNodeRole
resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter_node.name
}

// Attach AmazonEC2ContainerRegistryReadOnly to KarpenterNodeRole
resource "aws_iam_role_policy_attachment" "karpenter_node_ec2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter_node.name
}

// Attach AmazonEKS_CNI_Policy to KarpenterNodeRole
resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter_node.name
}

// Attach AmazonSSMManagedInstanceCore policy to KarpenterNodeRole
resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter_node.name
}
