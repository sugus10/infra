# Monitoring Module Variables

variable "name" {
  description = "Name prefix for monitoring resources"
  type        = string
}

variable "cluster_id" {
  description = "ID of the EKS cluster"
  type        = string
}

variable "budget_limit" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 50
}

variable "budget_notifications" {
  description = "List of budget notifications"
  type = list(object({
    comparison_operator        = string
    threshold                 = number
    threshold_type            = string
    notification_type         = string
    subscriber_email_addresses = list(string)
  }))
  default = [
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 80
      threshold_type            = "PERCENTAGE"
      notification_type         = "ACTUAL"
      subscriber_email_addresses = ["admin@example.com"]
    },
    {
      comparison_operator        = "GREATER_THAN"
      threshold                 = 100
      threshold_type            = "PERCENTAGE"
      notification_type         = "FORECASTED"
      subscriber_email_addresses = ["admin@example.com"]
    }
  ]
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
