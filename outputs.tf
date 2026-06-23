output "id" {
  description = "Bucket name (ID)."
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "Bucket ARN."
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "Global bucket domain name (bucket.s3.amazonaws.com)."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional bucket domain name — use this for in-region clients to avoid redirects."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
