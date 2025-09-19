locals {
  state_bucket_name = "${var.environment}-tfstate"
  state_key_alias   = "alias/${var.environment}_tfstate_key"
  state_table_name  = "${var.environment}_tfstate_table"
}

resource "aws_kms_key" "this" {
  description             = "This key is used to encrypt ${var.environment} Terraform state bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    Name        = local.state_bucket_name
    Environment = var.environment
  }
}

resource "aws_kms_alias" "this" {
  name          = local.state_key_alias
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_dynamodb_table" "this" {
  name           = "${var.environment}_tfstate_table"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "this" {
  bucket = local.state_bucket_name
  tags = {
    Name        = local.state_bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
