output "nat_gw_ip" {
  value = aws_nat_gateway.private_subnet[0].public_ip
}

output "eks_subnets" {
  value = aws_subnet.eks.*.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "vpc_id" {
  value = aws_vpc.main.id
}
