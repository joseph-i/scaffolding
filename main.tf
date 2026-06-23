# ---------------------------------------------------------------------------
# Secure-by-default S3 bucket.
#
# Hardening applied unconditionally:
#   - all public access blocked
#   - ACLs disabled (BucketOwnerEnforced ownership)
#   - server-side encryption (SSE-S3, or SSE-KMS when a key is supplied)
#   - a bucket policy that denies any request not made over TLS
#
# Everything else (versioning, access logging, lifecycle) is opt-in via
# variables so the module stays composable.
# ---------------------------------------------------------------------------

locals {
  # Use the supplied CMK when given, otherwise fall back to SSE-S3 (AES256).
  sse_algorithm  = var.kms_key_arn == null ? "AES256" : "aws:kms"
  has_lifecycle  = var.abort_incomplete_multipart_days != null || var.noncurrent_version_expiration_days != null
  has_versioning = var.versioning_enabled
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

# Disable ACLs entirely — the modern, recommended ownership model.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block every avenue of public exposure.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = local.has_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.sse_algorithm
      kms_master_key_id = var.kms_key_arn
    }

    # Bucket keys cut KMS request costs; only meaningful for SSE-KMS.
    bucket_key_enabled = var.kms_key_arn != null
  }
}

# Deny any request that does not use TLS.
data "aws_iam_policy_document" "this" {
  count = var.enforce_tls ? 1 : 0

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.enforce_tls ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json

  # The policy references the public access block, so apply it first to avoid
  # a window where a policy could be evaluated as "public".
  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_logging" "this" {
  count = var.logging_target_bucket == null ? 0 : 1

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = local.has_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "baseline"
    status = "Enabled"

    # Empty filter == apply to all objects in the bucket.
    filter {}

    dynamic "abort_incomplete_multipart_upload" {
      for_each = var.abort_incomplete_multipart_days == null ? [] : [1]
      content {
        days_after_initiation = var.abort_incomplete_multipart_days
      }
    }

    dynamic "noncurrent_version_expiration" {
      for_each = var.noncurrent_version_expiration_days == null ? [] : [1]
      content {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
    }
  }

  # Lifecycle rules that touch noncurrent versions require versioning to exist.
  depends_on = [aws_s3_bucket_versioning.this]
}
