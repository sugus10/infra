# Staging Environment Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

# Security Outputs
output "kms_key_id" {
  description = "KMS key ID used for EKS cluster encryption"
  value       = module.security.kms_key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for EKS cluster encryption"
  value       = module.security.kms_key_arn
}

# Monitoring Outputs
output "budget_name" {
  description = "Name of the AWS Budget for cost monitoring"
  value       = module.monitoring.budget_name
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarm names for monitoring"
  value       = module.monitoring.cloudwatch_alarms
}

# Staging-specific outputs
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost for staging environment"
  value       = "~$50-75 USD (t3.medium, single NAT gateway, 2-5 nodes)"
}
