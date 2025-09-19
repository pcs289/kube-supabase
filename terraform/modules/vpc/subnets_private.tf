locals {
  # 16384 IPs available for each subnet
  private_subnets = [
    "${local.cidr_prefix}.0.0/18",
    "${local.cidr_prefix}.64.0/18",
    "${local.cidr_prefix}.128.0/18",
  ]
}

resource "aws_subnet" "private" {
  count             = length(local.private_subnets)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.private_subnets[count.index]

  tags = {
    Name                                            = "${local.vpc_name}-private-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"               = "1"
    "karpenter.sh/discovery"                        = var.eks_cluster_name
    Environment                                     = var.environment
  }
}


###############################################################################
# Route table config for private subnets
###############################################################################

resource "aws_eip" "nat_gateway" {
  count  = var.single_nat_gateway ? 1 : length(local.private_subnets)
  domain = "vpc"
  tags = {
    Name        = "${local.vpc_name}-nat-gateway-${count.index}"
    Environment = local.vpc_name
  }
}

resource "aws_nat_gateway" "private_subnet" {
  count         = var.single_nat_gateway ? 1 : length(local.private_subnets)
  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${local.vpc_name}-private-subnet-${count.index}"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  count  = var.single_nat_gateway ? 1 : length(local.private_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_subnet[count.index].id
  }

  tags = {
    Name        = "${local.vpc_name}-private-${count.index}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}
