# Complete example

Exercises every feature of the module:

- **SSE-KMS** encryption with a customer-managed, rotation-enabled key
- **Server access logging** to a dedicated log bucket
- **Lifecycle rules** — abort stale multipart uploads, expire old versions

```bash
terraform init
terraform apply
```

> Change the `*-change-me` bucket names to globally unique values first.
>
> Because ACLs are disabled (`BucketOwnerEnforced`), the log bucket also needs
> a delivery policy granting `logging.s3.amazonaws.com` `s3:PutObject`. Wire
> that in via your account's logging baseline; it is intentionally out of scope
> for this single-bucket module.
