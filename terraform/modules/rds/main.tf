resource "aws_db_instance" "this" {

  identifier     = var.identifier
  instance_class = var.instance_class
  engine         = var.engine
  engine_version = var.engine_version

  username = var.master_user
  password = var.master_password

  allocated_storage     = var.storage
  max_allocated_storage = var.max_storage

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  multi_az                    = false
  deletion_protection         = false
  skip_final_snapshot         = true

  backup_retention_period = 30
  backup_window           = "05:45-06:15"
  maintenance_window      = "Sun:03:00-Sun:05:30"

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "this" {
  name        = "${var.identifier}-params"
  description = "DB parameter group for RDS Database: ${var.identifier}"
  family      = var.param_family

  dynamic "parameter" {
    for_each = var.db_params
    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }
}
