# Staging Environment Variables

# Environment Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eks-infra"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "platform-team"
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
  default     = "10.1.0.0/16"  # Different CIDR for staging
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private subnets"
  type        = bool
  default     = true  # Cost optimization for staging
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true  # Allow public access for staging
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]  # Medium instances for staging
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 5  # Moderate scaling for staging
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 2  # Start with 2 nodes for staging
}

# Security Configuration
variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# Cost Monitoring
variable "budget_alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "staging-team@example.com"
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 75  # Moderate budget for staging
}

# EKS Auto Mode Configuration
variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode instead of managed node groups"
  type        = bool
  default     = false  # Default to traditional mode for staging
}

variable "auto_mode_instance_types" {
  description = "Instance types for EKS Auto Mode"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "auto_mode_min_capacity" {
  description = "Minimum capacity for EKS Auto Mode"
  type        = number
  default     = 2
}

variable "auto_mode_max_capacity" {
  description = "Maximum capacity for EKS Auto Mode"
  type        = number
  default     = 5
}

# Additional tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Environment = "staging"
    Project     = "eks-infra"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}
