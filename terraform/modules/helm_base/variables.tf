variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_data" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "karpenter" {
  type = object({
    fargate_role_arn : string
    irsa_role_arn : string
    worker_role_arn : string
  })
}
