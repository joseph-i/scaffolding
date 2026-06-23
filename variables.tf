variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique and DNS-compliant."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 chars, lowercase, and may contain only letters, numbers, hyphens, and dots."
  }
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even when it still contains objects. Keep false outside of throwaway environments."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of a KMS key for SSE-KMS encryption. When null, the bucket uses SSE-S3 (AES256)."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws[a-z-]*:kms:", var.kms_key_arn))
    error_message = "kms_key_arn must be a valid KMS key ARN or null."
  }
}

variable "enforce_tls" {
  description = "Attach a bucket policy that denies any request not made over TLS."
  type        = bool
  default     = true
}

variable "logging_target_bucket" {
  description = "Bucket that receives server access logs. When null, access logging is disabled."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Key prefix for delivered access logs."
  type        = string
  default     = "s3-access-logs/"
}

variable "abort_incomplete_multipart_days" {
  description = "Days after which incomplete multipart uploads are aborted. When null, no such rule is created."
  type        = number
  default     = 7

  validation {
    condition     = var.abort_incomplete_multipart_days == null ? true : var.abort_incomplete_multipart_days > 0
    error_message = "abort_incomplete_multipart_days must be a positive number or null."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent object versions expire. When null, noncurrent versions are retained indefinitely."
  type        = number
  default     = null

  validation {
    condition     = var.noncurrent_version_expiration_days == null ? true : var.noncurrent_version_expiration_days > 0
    error_message = "noncurrent_version_expiration_days must be a positive number or null."
  }
}
