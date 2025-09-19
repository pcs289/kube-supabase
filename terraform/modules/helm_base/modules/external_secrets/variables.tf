variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "service_account" {
  type    = string
  default = "external-secrets"
}

variable "namespace" {
  type    = string
  default = "external-secrets"
}
