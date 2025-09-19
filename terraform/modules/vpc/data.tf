data "aws_region" "this" {}
data "aws_availability_zones" "available" {
  state = "available"
}
