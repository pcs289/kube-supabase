output "domain" {
  value = "${aws_s3_bucket.this.id}.s3.amazonaws.com"
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "id" {
  value = aws_s3_bucket.this.id
}
