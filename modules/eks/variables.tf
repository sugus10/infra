# EKS Module Variables

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 10
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_security_group_id" {
  description = "Security group ID for the node group"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for cluster encryption"
  type        = string
}

# aws_auth variables removed in version 20.0+ - managed differently

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# EKS Auto Mode Configuration
variable "enable_auto_mode" {
  description = "Enable EKS Auto Mode instead of managed node groups"
  type        = bool
  default     = false
}

variable "auto_mode_instance_types" {
  description = "Instance types for EKS Auto Mode (only used when enable_auto_mode is true)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "auto_mode_min_capacity" {
  description = "Minimum capacity for EKS Auto Mode (only used when enable_auto_mode is true)"
  type        = number
  default     = 1
}

variable "auto_mode_max_capacity" {
  description = "Maximum capacity for EKS Auto Mode (only used when enable_auto_mode is true)"
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
