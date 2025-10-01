# Monitoring Module Outputs

output "budget_name" {
  description = "Name of the AWS Budget for cost monitoring"
  value       = aws_budgets_budget.eks_cost.name
}

output "budget_arn" {
  description = "ARN of the AWS Budget"
  value       = aws_budgets_budget.eks_cost.arn
}

output "cloudwatch_alarms" {
  description = "CloudWatch alarm names for monitoring"
  value = {
    cpu_alarm    = aws_cloudwatch_metric_alarm.cluster_cpu_high.alarm_name
    memory_alarm = aws_cloudwatch_metric_alarm.cluster_memory_high.alarm_name
  }
}

output "cloudwatch_alarm_arns" {
  description = "CloudWatch alarm ARNs for monitoring"
  value = {
    cpu_alarm    = aws_cloudwatch_metric_alarm.cluster_cpu_high.arn
    memory_alarm = aws_cloudwatch_metric_alarm.cluster_memory_high.arn
  }
}
