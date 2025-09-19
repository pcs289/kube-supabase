###############################################################################
# IAM role for EKS Worker Nodes
###############################################################################

resource "aws_iam_role" "eks_nodes" {
  name               = "${var.cluster_name}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_workers.json
}

// Allow EC2 service to assume EKSWorkerRole
data "aws_iam_policy_document" "assume_workers" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// Attach AmazonEKSWorkerNodePolicy to EKSWorkerRole
resource "aws_iam_role_policy_attachment" "aws_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonEKS_CNI_Policy to EKSWorkerRole
resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonEC2ContainerRegistryReadOnly policy to EKSWorkerRole
resource "aws_iam_role_policy_attachment" "aws_eks_ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

// Attach AmazonSSMManagedInstanceCore policy to EKSWorkerRole
resource "aws_iam_role_policy_attachment" "aws_eks_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodes.name
}
