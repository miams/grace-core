variable "account_ids" {
  type = "list"
}

variable "name" {
  type = "string"
}

variable "budget_limit" {
  type        = "string"
  description = "Budget limit, as an integer"
}

variable "budget_notification_topic_arn" {
  type = "string"
}

variable "warning_threshold_pct" {
  default     = "80"
  description = "The percentage of budget used at which a warning is sent to the finance team"
}
