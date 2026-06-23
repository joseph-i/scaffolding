provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# Customer-managed key for SSE-KMS encryption of the primary bucket.
resource "aws_kms_key" "this" {
  description             = "Encryption key for the example data bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Dedicated bucket to receive server access logs.
module "log_bucket" {
  source = "../../"

  bucket_name = "example-complete-logs-change-me"

  # Access-log delivery cannot itself be logged, and KMS on a log bucket
  # complicates delivery, so this one stays on SSE-S3.
  tags = {
    Environment = "prod"
    Purpose     = "access-logs"
  }
}

# Primary bucket: KMS-encrypted, logging to the bucket above, with a
# lifecycle policy that ages out old versions and incomplete uploads.
module "bucket" {
  source = "../../"

  bucket_name = "example-complete-data-change-me"

  kms_key_arn = aws_kms_key.this.arn

  logging_target_bucket = module.log_bucket.id
  logging_target_prefix = "data-bucket/"

  abort_incomplete_multipart_days    = 7
  noncurrent_version_expiration_days = 90

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Owner       = data.aws_caller_identity.current.account_id
  }
}
