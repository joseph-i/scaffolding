provider "aws" {
  region = "us-east-1"
}

# Minimal usage: a private, encrypted, versioned bucket with TLS enforced.
module "bucket" {
  source = "../../"

  bucket_name = "example-basic-bucket-change-me"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
