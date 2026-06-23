.PHONY: help fmt validate lint scan docs check

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate: ## Init (no backend) and validate the module
	terraform init -backend=false
	terraform validate

lint: ## Run tflint across the module and examples
	tflint --recursive

scan: ## Run a Trivy IaC misconfiguration scan
	trivy config --severity CRITICAL,HIGH .

docs: ## Regenerate the inputs/outputs tables in README.md
	terraform-docs markdown table --output-file README.md --output-mode inject .

check: fmt validate lint scan ## Run the full local check suite
