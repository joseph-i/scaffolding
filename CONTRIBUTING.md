# Contributing

Thanks for taking a look. This repo doubles as a template for new Terraform
modules, so the bar is "would I want to copy this structure into the next
module" — keep it tidy.

## Local checks

Install the tooling (`terraform`, [`tflint`](https://github.com/terraform-linters/tflint),
[`trivy`](https://github.com/aquasecurity/trivy), [`terraform-docs`](https://github.com/terraform-docs/terraform-docs)),
then:

```bash
make check   # fmt + validate + lint + scan
make docs    # regenerate the README inputs/outputs tables
```

Or install the git hooks so it happens automatically:

```bash
pre-commit install
```

## Conventions

- Run `make fmt` before committing; CI fails on unformatted code.
- Keep resources secure-by-default; anything that loosens posture should be
  opt-in via a variable with a safe default.
- Document every variable and output, and add an example when you add a feature.
- Update `CHANGELOG.md` under `[Unreleased]`.
