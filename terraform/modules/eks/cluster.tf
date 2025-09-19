###############################################################################
# EKS Cluster
###############################################################################

resource "aws_eks_cluster" "main" {
  version  = var.eks_version
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_access_cidrs
    subnet_ids              = var.eks_subnets
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_cidr
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name                                        = var.cluster_name
    Environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
    "karpenter.sh/cluster/${var.cluster_name}"  = var.cluster_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_cluster_policy,
    aws_iam_role_policy_attachment.aws_eks_service_policy,
    aws_iam_role_policy_attachment.aws_eks_vpc_policy,
  ]
}


resource "aws_security_group_rule" "eks_worker" {
  description              = "Allow EKS traffic to Worker"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_nodes.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cp" {
  description              = "Allow EKS traffic to ControlPlane"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_cluster.id
  type                     = "ingress"
}
