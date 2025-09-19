variable "allow_ssh_cidrs" {
  type = list(string)
}

variable "eks_cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "vpc_cidr_block" {
  type = string
}
