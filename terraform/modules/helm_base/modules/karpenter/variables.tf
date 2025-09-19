variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "environment" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "irsa_role_arn" {
  type = string
}

variable "worker_role_arn" {
  type = string
}
