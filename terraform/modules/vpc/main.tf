locals {
  vpc_name = "${var.environment}-vpc"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name                                            = local.vpc_name
    Environment                                     = var.environment
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}
