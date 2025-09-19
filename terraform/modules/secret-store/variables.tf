variable "secrets" {
  description = "A map of secrets where keys are secret names and values are KMS-encrypted blobs."
  type        = map(string)
  default     = {}
}

variable "environment" {
  type = string
}

variable "name" {
  type        = string
  description = "SecretStore Name"
}

variable "external_secret_role" {
  type        = string
  description = "Role ARN of ExternalSecret ServiceAccount"
}
