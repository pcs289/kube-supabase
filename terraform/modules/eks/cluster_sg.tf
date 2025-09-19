###############################################################################
# Security Group for EKS Control Plane Nodes
###############################################################################

resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
  tags = {
    Name                                        = "${var.cluster_name}-sg"
    Environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
    "karpenter.sh/cluster/${var.cluster_name}"  = var.cluster_name
  }
}

// Allow HTTPS inbound traffic from EKS Worker Nodes
resource "aws_security_group_rule" "eks_i_https_worker" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

// Allow ALL outbound traffic to anywhere
resource "aws_security_group_rule" "eks_o_anywhere" {
  description       = "Allow outbound traffic to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
}
