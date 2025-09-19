locals {
  # 2048 IPs available for each subnet
  public_subnets = [
    "${local.cidr_prefix}.192.0/21",
    "${local.cidr_prefix}.200.0/21",
    "${local.cidr_prefix}.208.0/21",
  ]
}

resource "aws_subnet" "public" {
  count                   = length(local.public_subnets)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = local.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${local.vpc_name}-public-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
    Environment                                     = var.environment
  }
}

###############################################################################
# Route table config for public subnets
###############################################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = local.vpc_name
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${local.vpc_name}-public"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
