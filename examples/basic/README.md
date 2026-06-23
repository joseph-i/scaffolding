# Basic example

The smallest possible usage: a private bucket that is encrypted (SSE-S3),
versioned, and TLS-only out of the box.

```bash
terraform init
terraform apply
```

> Change `bucket_name` to something globally unique before applying.
