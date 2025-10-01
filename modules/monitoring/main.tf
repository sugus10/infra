# Monitoring Module
# This module handles CloudWatch monitoring, budgets, and alarms

# CloudWatch Alarms for EKS Monitoring
resource "aws_cloudwatch_metric_alarm" "cluster_cpu_high" {
  alarm_name          = "${var.name}-cluster-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS cluster CPU utilization"
  alarm_actions       = []

  dimensions = {
    ClusterName = var.cluster_id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cluster_memory_high" {
  alarm_name          = "${var.name}-cluster-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EKS cluster memory utilization"
  alarm_actions       = []

  dimensions = {
    ClusterName = var.cluster_id
  }

  tags = var.tags
}

# Cost Monitoring - AWS Budgets
resource "aws_budgets_budget" "eks_cost" {
  name         = "${var.name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = var.budget_notifications
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                 = notification.value.threshold
      threshold_type            = notification.value.threshold_type
      notification_type         = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses
    }
  }

  tags = var.tags
}
