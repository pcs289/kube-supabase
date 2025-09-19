variable "bucket_name" {
  type        = string
  description = "Globally Unique Bucket Name"
}

variable "bucket_encrypted" {
  type        = bool
  description = "Enable S3 Bucket Encryption"
  default     = true
}

variable "bucket_versioned" {
  type        = bool
  description = "Enable S3 Bucket Versioning"
  default     = true
}
