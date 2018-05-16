variable "account_ids" {
  default     = []
  description = "If no account IDs are specified, applies to the master account"
}

variable "name" {
  type = "string"
}

variable "budget_limit" {
  type        = "string"
  description = "Budget limit, as an integer"
}

variable "budget_notifications" {
  default     = []
  description = "A list of where to send notifications for budget alerts. Each list element should be a map with `protocol` and `endpoint` keys. More information about allowed values: https://docs.aws.amazon.com/sns/latest/api/API_Subscribe.html#API_Subscribe_RequestParameters"
}

locals {
  # the finance team
  default_budget_notifications = [
    {
      protocol = "email"
      endpoint = "aidan.feldman+devsecops-finance@gsa.gov"
    },
  ]

  all_budget_notifications = "${concat(local.default_budget_notifications, var.budget_notifications)}"
}

variable "warning_threshold_pct" {
  default     = "80"
  description = "The percentage of budget used at which a warning is sent to the finance team"
}
