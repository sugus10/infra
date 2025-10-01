# Staging Environment Configuration
# This configuration is optimized for staging with moderate resources

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "staging"
      Project     = var.project_name
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  name = "${var.project_name}-${var.environment}"
  region = var.aws_region

  vpc_cidr = var.vpc_cidr
  azs = slice(data.aws_availability_zones.available.names, 0, 3)  # All 3 AZs for staging

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${local.name}" = "shared"
    Environment = "staging"
    CostCenter  = "staging"
  })
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  vpc_cidr          = local.vpc_cidr
  single_nat_gateway = var.single_nat_gateway  # Configurable for staging
  tags              = local.tags
}

# Security Module (KMS and IAM only)
module "security" {
  source = "../../modules/security"

  name                        = local.name
  vpc_id                     = module.vpc.vpc_id
  cluster_security_group_id  = ""  # Will be updated after EKS creation
  oidc_provider_arn          = ""  # Will be updated after EKS creation
  oidc_provider              = ""  # Will be updated after EKS creation
  tags                       = local.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name                    = local.name
  kubernetes_version             = var.kubernetes_version
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnets
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  node_instance_types           = var.node_instance_types
  node_group_min_size           = var.node_group_min_size
  node_group_max_size           = var.node_group_max_size
  node_group_desired_size       = var.node_group_desired_size
  node_group_security_group_id  = ""  # Will be created by EKS module
  kms_key_arn                   = module.security.kms_key_arn
  aws_auth_roles                = var.aws_auth_roles
  aws_auth_users                = var.aws_auth_users
  tags                          = local.tags

  depends_on = [module.security]
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  name      = local.name
  cluster_id = module.eks.cluster_id
  budget_limit = var.budget_limit
  budget_notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = [var.budget_alert_email]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 100
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = [var.budget_alert_email]
    }
  ]
  tags = local.tags

  depends_on = [module.eks]
}
