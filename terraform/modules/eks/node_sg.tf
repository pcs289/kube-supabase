###############################################################################
# Security Group for EKS Worker Nodes
###############################################################################

resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-worker-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id
  tags = {
    Name                                        = "${var.cluster_name}-worker-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
    "karpenter.sh/cluster/${var.cluster_name}"  = var.cluster_name
  }
}

// Allow ALL outbound traffic to anywhere
resource "aws_security_group_rule" "worker_o_anywhere" {
  description       = "Allow outbound traffic to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
}

// Allow ALL inbound traffic between EKS Worker Nodes
resource "aws_security_group_rule" "worker_i_worker" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 0
  type                     = "ingress"
}

// Allow Ephemeral ports inbound traffic from EKS Control Plane
resource "aws_security_group_rule" "worker_i_ephemeral_eks" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

// Allow UDP Ephemeral ports inbound traffic from EKS Control Plane
resource "aws_security_group_rule" "worker_udp_i_ephemeral_eks" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "udp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}
