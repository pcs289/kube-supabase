locals {
  bucket_versioning = var.bucket_versioned ? "Enabled" : "Disabled"
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = local.bucket_versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = var.bucket_name

  rule {
    bucket_key_enabled = var.bucket_encrypted
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
