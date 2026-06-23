# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial secure-by-default S3 bucket module.
- Public access block, ACLs disabled (`BucketOwnerEnforced`), SSE-S3/SSE-KMS
  encryption, and a TLS-only bucket policy applied by default.
- Opt-in versioning, server access logging, and lifecycle rules.
- `basic` and `complete` usage examples.
- CI: `terraform fmt`/`validate`, TFLint, and Trivy IaC scanning.
