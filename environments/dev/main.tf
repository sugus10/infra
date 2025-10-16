# Development Environment Configuration
# This configuration is optimized for development with minimal costs

terraform {
  required_version = ">= 1.6"  # Latest stable version
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.79"  # Compatible with EKS module 20.37
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.aws_region

  # Use test account profile for testing
  profile = "test"

  default_tags {
    tags = {
      Environment = "development"
      Project     = var.project_name
      ManagedBy   = "terraform"
      Owner       = var.owner
      Account     = "test"
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
  name   = "${var.project_name}-${var.environment}"
  region = var.aws_region

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 2) # Only 2 AZs for dev

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${local.name}" = "shared"
    Environment                           = "development"
    CostCenter                            = "development"
  })
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  vpc_cidr           = local.vpc_cidr
  single_nat_gateway = true # Cost optimization for dev
  tags               = local.tags
}

# Security Module (KMS and IAM only)
module "security" {
  source = "../../modules/security"

  name                      = local.name
  vpc_id                    = module.vpc.vpc_id
  cluster_security_group_id = "" # Will be updated after EKS creation
  oidc_provider_arn         = "" # Will be updated after EKS creation
  oidc_provider             = "" # Will be updated after EKS creation
  tags                      = local.tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name                   = local.name
  kubernetes_version             = var.kubernetes_version
  vpc_id                         = module.vpc.vpc_id
  private_subnet_ids             = module.vpc.private_subnets
  cluster_endpoint_public_access = true # Allow public access for dev
  node_instance_types            = var.node_instance_types
  node_group_min_size            = var.node_group_min_size
  node_group_max_size            = var.node_group_max_size
  node_group_desired_size        = var.node_group_desired_size
  node_group_security_group_id   = "" # Will be created by EKS module
  kms_key_arn                    = module.security.kms_key_arn
  tags                           = local.tags

  # EKS Auto Mode Configuration
  enable_auto_mode         = var.enable_auto_mode
  auto_mode_instance_types = var.auto_mode_instance_types
  auto_mode_min_capacity   = var.auto_mode_min_capacity
  auto_mode_max_capacity   = var.auto_mode_max_capacity

  # Cost Optimization Configuration
  enable_spot_instances = var.enable_spot_instances
  auto_shutdown_enabled = var.auto_shutdown_enabled
  weekend_shutdown      = var.weekend_shutdown

  depends_on = [module.security]
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  name         = local.name
  cluster_id   = module.eks.cluster_id
  budget_limit = var.budget_limit
  budget_notifications = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.budget_alert_email]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 100
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = [var.budget_alert_email]
    }
  ]
  tags = local.tags

  depends_on = [module.eks]
}
