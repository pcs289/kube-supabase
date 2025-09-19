locals {
  cidr_prefix = regex("\\d{1,3}.\\d{1,3}", var.vpc_cidr_block)

  # It is best practice to use small (/28) dedicated subnets for Amazon EKS to create network interfaces
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  eks_subnets = [
    "${local.cidr_prefix}.255.0/28",
    "${local.cidr_prefix}.255.16/28",
    "${local.cidr_prefix}.255.32/28",
  ]
}

resource "aws_subnet" "eks" {
  count             = length(local.eks_subnets)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.eks_subnets[count.index]

  tags = {
    Name                                            = "${local.vpc_name}-eks-${data.aws_availability_zones.available.names[count.index]}"
    Environment                                     = var.environment
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "karpenter.sh/discovery"                        = var.eks_cluster_name
  }
}

resource "aws_route_table_association" "eks" {
  count          = length(local.eks_subnets)
  subnet_id      = aws_subnet.eks[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}