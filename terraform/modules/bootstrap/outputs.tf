output "state_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "state_bucket_name" {
  value = local.state_bucket_name
}

output "state_key_alias" {
  value = local.state_key_alias
}

output "state_table_name" {
  value = local.state_table_name
}
