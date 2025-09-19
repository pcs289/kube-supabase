variable "environment" {
  type        = string
  description = "Environment Name"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}

variable "cluster_cidr" {
  type        = string
  description = "EKS Cluster CIDR"
  default     = "10.100.0.0/16"
}

variable "cluster_version" {
  type        = string
  description = "EKS Cluster version"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "vpc_single_nat" {
  type        = bool
  description = "VPC Single NAT Gateway"
  default     = true
}

variable "allow_ssh_cidrs" {
  type        = list(string)
  description = "List of allowed SSH CIDRs"
}

variable "allow_ssh_keys" {
  type        = list(string)
  description = "List of allowed SSH Keys"
}

##############################
## RDS
##############################
variable "db_identifier" {
  type        = string
  description = "RDS Database Name"
}

variable "db_master_user" {
  type        = string
  description = "RDS Database Master User"
}

variable "db_instance_class" {
  type        = string
  description = "RDS Database Instance Class"
  default     = "db.t3.small"
}

variable "db_engine" {
  type        = string
  description = "RDS Database Engine"
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  description = "RDS Database Engine"
  default     = "17.1"
}

variable "db_storage" {
  type        = number
  description = "RDS Database Base Storage"
  default     = 20
}

variable "db_max_storage" {
  type        = number
  description = "RDS Database Max Storage"
  default     = 50
}

variable "db_params" {
  type        = list(any)
  description = "RDS Database Parameter"
  default     = []
}

##############################
## S3
##############################
variable "bucket_name" {
  type        = string
  description = "S3 Bucket Name"
}
variable "bucket_encrypted" {
  type        = bool
  description = "Enable S3 Bucket Encryption"
  default     = false
}
variable "bucket_versioned" {
  type        = bool
  description = "Enable S3 Bucket Versioning"
  default     = false
}

##############################
## Secrets
##############################

variable "secretstore_name" {
  type        = string
  description = "Name of SecretStore"
}

variable "secrets" {
  type        = map(string)
  description = "Map of Secrets"
  default     = {}
}
