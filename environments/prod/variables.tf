# Production Environment Variables

# Environment Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
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
  default     = "10.2.0.0/16" # Different CIDR for production
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private subnets"
  type        = bool
  default     = false # High availability for production
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
  default     = false # Private access for production security
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge"] # Larger instances for production
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 3 # Minimum 3 nodes for high availability
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 10 # Higher scaling for production
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3 # Start with 3 nodes for production
}

# Security Configuration
# Note: aws-auth management is now handled by the EKS module in version 20.0+

# Cost Monitoring
variable "budget_alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "platform-team@example.com"
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 200 # Higher budget for production
}

# EKS Auto Mode Configuration
variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode instead of managed node groups"
  type        = bool
  default     = false # Default to traditional mode for production
}

variable "auto_mode_instance_types" {
  description = "Instance types for EKS Auto Mode"
  type        = list(string)
  default     = ["t3.large", "t3.xlarge"]
}

variable "auto_mode_min_capacity" {
  description = "Minimum capacity for EKS Auto Mode"
  type        = number
  default     = 3
}

variable "auto_mode_max_capacity" {
  description = "Maximum capacity for EKS Auto Mode"
  type        = number
  default     = 10
}

# Cost Optimization Variables
variable "enable_spot_instances" {
  description = "Enable Spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "auto_shutdown_enabled" {
  description = "Enable auto-shutdown for cost savings"
  type        = bool
  default     = false
}

variable "weekend_shutdown" {
  description = "Enable weekend shutdown for additional cost savings"
  type        = bool
  default     = false
}

# Additional tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "eks-infra"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
}
