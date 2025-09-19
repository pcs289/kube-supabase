###############################################################################
# ACL rules for private subnets
###############################################################################

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = concat(aws_subnet.private.*.id, aws_subnet.eks.*.id)

  tags = {
    Name        = "${local.vpc_name}-private"
    Environment = var.environment
  }
}

##
## SSH
##

# Allow SSH outbound traffic to allowed_ssh_cidrs IPs
resource "aws_network_acl_rule" "private_o_allowed_ssh" {
  for_each       = { for idx, cidr in var.allow_ssh_cidrs : idx => cidr }
  protocol       = "tcp"
  rule_number    = 200 + each.key
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = 22
  to_port        = 22
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

# Allow SSH outbound traffic to VPC
resource "aws_network_acl_rule" "private_o_ssh_vpc" {
  protocol       = "tcp"
  rule_number    = 199
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_block
  from_port      = 22
  to_port        = 22
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

##
## HTTPS
##

# Allow HTTPS inbound traffic from the VPC
resource "aws_network_acl_rule" "private_i_https_vpc" {
  protocol       = "tcp"
  rule_number    = 100
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  network_acl_id = aws_network_acl.private.id
  egress         = false
}

# Allow HTTPS outbound traffic to anywhere
resource "aws_network_acl_rule" "private_o_https_any" {
  protocol       = "tcp"
  rule_number    = 100
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

##
## HTTP
##

# Allow HTTP inbound traffic from the VPC
resource "aws_network_acl_rule" "private_i_http_vpc" {
  protocol       = "tcp"
  rule_number    = 110
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  network_acl_id = aws_network_acl.private.id
  egress         = false
}

# Allow HTTP outbound traffic to VPC
resource "aws_network_acl_rule" "private_o_http_vpc" {
  protocol       = "tcp"
  rule_number    = 110
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

##
## Ephemeral Ports
##

# Allow Ephemeral ports inbound traffic from anywhere for NAT gateways on public subnets
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html#nacl-ephemeral-ports
resource "aws_network_acl_rule" "private_i_ephemeral_any" {
  protocol       = "tcp"
  rule_number    = 120
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.private.id
  egress         = false
}

# Allow Ephemeral ports outbound traffic to anywhere
resource "aws_network_acl_rule" "private_o_ephemeral_ports_anywhere" {
  protocol       = "tcp"
  rule_number    = 120
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

# Allow UDP Ephemeral ports inbound traffic from anywhere for NAT gateways on public subnets
# https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html#nacl-ephemeral-ports
resource "aws_network_acl_rule" "private_i_ephemeral_any_udp" {
  protocol       = "udp"
  rule_number    = 121
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.private.id
  egress         = false
}

# Allow UDP Ephemeral ports outbound traffic to anywhere
resource "aws_network_acl_rule" "private_o_ephemeral_ports_anywhere_udp" {
  protocol       = "udp"
  rule_number    = 121
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

##
## DNS
##

# Allow TCP inbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "private_i_dns_tcp" {
  protocol       = "tcp"
  rule_number    = 130
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.private.id
  egress         = false
}

# Allow TCP outbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "private_o_dns_tcp" {
  protocol       = "tcp"
  rule_number    = 130
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.private.id
  egress         = true
}

# Allow UDP inbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "private_i_dns_udp" {
  protocol       = "udp"
  rule_number    = 131
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.private.id
  egress         = false
}

# Allow UDP outbound traffic for DNS services inside the VPC
resource "aws_network_acl_rule" "private_o_dns_udp" {
  protocol       = "udp"
  rule_number    = 131
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
  network_acl_id = aws_network_acl.private.id
  egress         = true
}
