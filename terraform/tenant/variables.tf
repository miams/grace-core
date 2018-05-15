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
