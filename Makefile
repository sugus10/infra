# Makefile for EKS Infrastructure Management
# This file provides convenient commands for managing the EKS infrastructure

.PHONY: help init plan apply destroy validate format check-deps clean

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Terraform commands
init: ## Initialize Terraform
	terraform init

plan: ## Plan Terraform changes
	terraform plan

apply: ## Apply Terraform changes
	terraform apply

destroy: ## Destroy Terraform resources
	terraform destroy

validate: ## Validate Terraform configuration
	terraform validate

format: ## Format Terraform files
	terraform fmt -recursive

# Dependency checks
check-deps: ## Check if required tools are installed
	@echo "Checking dependencies..."
	@command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed. Aborting." >&2; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLI is required but not installed. Aborting." >&2; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting." >&2; exit 1; }
	@echo "All dependencies are installed."

# AWS EKS specific commands
update-kubeconfig: ## Update kubeconfig for the EKS cluster
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "Please set CLUSTER_NAME environment variable"; \
		echo "Usage: make update-kubeconfig CLUSTER_NAME=my-cluster"; \
		exit 1; \
	fi
	aws eks update-kubeconfig --region $(AWS_REGION) --name $(CLUSTER_NAME)

get-cluster-info: ## Get cluster information
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "Please set CLUSTER_NAME environment variable"; \
		echo "Usage: make get-cluster-info CLUSTER_NAME=my-cluster"; \
		exit 1; \
	fi
	aws eks describe-cluster --name $(CLUSTER_NAME) --region $(AWS_REGION)

get-node-groups: ## Get node group information
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "Please set CLUSTER_NAME environment variable"; \
		echo "Usage: make get-node-groups CLUSTER_NAME=my-cluster"; \
		exit 1; \
	fi
	aws eks list-nodegroups --cluster-name $(CLUSTER_NAME) --region $(AWS_REGION)

# Cleanup commands
clean: ## Clean up temporary files
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f crash.log
	rm -f *.log

# Development commands
dev-setup: check-deps init ## Set up development environment
	@echo "Development environment setup complete."

# Production deployment
prod-deploy: check-deps init plan apply ## Deploy to production (with confirmation)
	@echo "Production deployment complete."

# Staging deployment
staging-deploy: check-deps init apply ## Deploy to staging
	@echo "Staging deployment complete."

# Security checks
security-scan: ## Run security scan on Terraform files
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "tfsec is not installed. Install it with: brew install tfsec"; \
	fi

# Cost estimation
cost-estimate: ## Estimate costs (requires infracost)
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost is not installed. Install it from https://www.infracost.io/"; \
	fi

# Documentation
docs: ## Generate documentation
	@echo "Generating documentation..."
	@terraform-docs markdown . > README.md

# All-in-one commands
full-deploy: check-deps init plan apply update-kubeconfig ## Full deployment with kubeconfig update
	@echo "Full deployment complete."

# Environment variables
AWS_REGION ?= us-west-2
CLUSTER_NAME ?= eks-cluster
