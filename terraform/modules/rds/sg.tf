resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security Group for RDS Database: ${var.identifier}"
  vpc_id      = var.vpc_id
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_security_group_rule" "this" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = data.aws_vpc.this.cidr_block_associations[*].cidr_block
}
