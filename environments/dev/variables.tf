# Development Environment Variables

# Environment Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eks-infra"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "development-team"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.small"]  # Cost-optimized for dev
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 3  # Lower max for dev
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 1  # Start with 1 node for dev
}

# Security Configuration
# Note: aws-auth management is now handled by the EKS module in version 20.0+

# Cost Monitoring
variable "budget_alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "dev-team@example.com"
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 25  # Lower budget for dev
}

# EKS Auto Mode Configuration
variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode instead of managed node groups"
  type        = bool
  default     = false  # Default to traditional mode for dev
}

variable "auto_mode_instance_types" {
  description = "Instance types for EKS Auto Mode"
  type        = list(string)
  default     = ["t3.small"]
}

variable "auto_mode_min_capacity" {
  description = "Minimum capacity for EKS Auto Mode"
  type        = number
  default     = 1
}

variable "auto_mode_max_capacity" {
  description = "Maximum capacity for EKS Auto Mode"
  type        = number
  default     = 3
}

# Additional tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "eks-infra"
    ManagedBy   = "terraform"
    Owner       = "development-team"
  }
}
