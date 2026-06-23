output "bucket_arn" {
  description = "ARN of the primary data bucket."
  value       = module.bucket.arn
}

output "log_bucket_arn" {
  description = "ARN of the access-log bucket."
  value       = module.log_bucket.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting the data bucket."
  value       = aws_kms_key.this.arn
}
