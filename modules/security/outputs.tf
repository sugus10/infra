# Security Module Outputs

output "kms_key_id" {
  description = "KMS key ID used for EKS cluster encryption"
  value       = aws_kms_key.eks.key_id
}

output "kms_key_arn" {
  description = "KMS key ARN used for EKS cluster encryption"
  value       = aws_kms_key.eks.arn
}

output "kms_alias_name" {
  description = "KMS alias name"
  value       = aws_kms_alias.eks.name
}

output "node_group_security_group_id" {
  description = "Security group ID for EKS node groups"
  value       = var.cluster_security_group_id != "" ? aws_security_group.node_group[0].id : ""
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the cluster autoscaler IAM role"
  value       = var.oidc_provider_arn != "" ? aws_iam_role.cluster_autoscaler[0].arn : ""
}

output "cluster_autoscaler_role_name" {
  description = "Name of the cluster autoscaler IAM role"
  value       = var.oidc_provider_arn != "" ? aws_iam_role.cluster_autoscaler[0].name : ""
}
