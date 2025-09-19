###############################################################################
# ACL rules for public subnets
###############################################################################

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name        = "${local.vpc_name}-public"
    Environment = var.environment
  }
}

##
## SSH
##

# Allow SSH outbound traffic to allowed_ssh_cidrs IPs
resource "aws_network_acl_rule" "public_o_allowed_ssh" {
  for_each = { for idx, cidr in var.allow_ssh_cidrs : idx => cidr }

  protocol       = "tcp"
  rule_number    = 300 + each.key
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 22
  to_port        = 22
  network_acl_id = aws_network_acl.public.id
  egress         = true
}

# Allow SSH inbound traffic from VPC
resource "aws_network_acl_rule" "public_i_ssh_vpc" {
  protocol       = "tcp"
  rule_number    = 200
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_block
  from_port      = 22
  to_port        = 22
  network_acl_id = aws_network_acl.public.id
  egress         = false
}

##
## HTTPS
##

# Allows HTTPS outbound traffic to anywhere
resource "aws_network_acl_rule" "public_o_https_any" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allows HTTPS inbound traffic from anywhere
resource "aws_network_acl_rule" "public_i_https_any" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

##
## HTTP
##

# Allow HTTP inbound traffic from VPC
resource "aws_network_acl_rule" "public_i_http_vpc" {
  protocol       = "tcp"
  rule_number    = 110
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  network_acl_id = aws_network_acl.public.id
  egress         = false
}

# Allow HTTP outbound traffic to VPC
resource "aws_network_acl_rule" "public_o_http_vpc" {
  protocol       = "tcp"
  rule_number    = 110
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  network_acl_id = aws_network_acl.public.id
  egress         = true
}

##
## Ephemeral Ports
##

# Allow Ephemeral ports inbound traffic from anywhere for NAT gateways and load balancers on public subnets
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html#nacl-ephemeral-ports
resource "aws_network_acl_rule" "public_i_ephemeral_any" {
  protocol       = "tcp"
  rule_number    = 120
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.public.id
  egress         = false
}

# Allow Ephemeral ports outbound traffic to anywhere
resource "aws_network_acl_rule" "public_o_ephemeral_any" {
  protocol       = "tcp"
  rule_number    = 120
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.public.id
  egress         = true
}

# Allow Ephemeral ports inbound traffic from anywhere for NAT gateways and load balancers on public subnets
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html#nacl-ephemeral-ports
resource "aws_network_acl_rule" "public_i_ephemeral_any_udp" {
  protocol       = "udp"
  rule_number    = 121
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.public.id
  egress         = false
}

# Allow Ephemeral ports outbound traffic to anywhere
resource "aws_network_acl_rule" "public_o_ephemeral_any_udp" {
  protocol       = "udp"
  rule_number    = 121
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.public.id
  egress         = true
}


##
## DNS
##

# Allow TCP inbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "public_i_dns_tcp" {
  protocol       = "tcp"
  rule_number    = 130
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.public.id
  egress         = false
}

# Allow TCP outbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "public_o_dns_tcp" {
  protocol       = "tcp"
  rule_number    = 130
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.public.id
  egress         = true
}

# Allow UDP inbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "public_i_dns_udp" {
  protocol       = "udp"
  rule_number    = 131
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.public.id
  egress         = false
}

# Allow UDP outbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "public_o_dns_udp" {
  protocol       = "udp"
  rule_number    = 131
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.public.id
  egress         = true
}

