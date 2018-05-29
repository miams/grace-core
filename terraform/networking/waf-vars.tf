variable "mgmt_access_log_bucket" {
  type        = "string"
  default     = "mgmt-waf-access-log"
  description = "Name of S3 bucket for mgmt account ALB access logs. Default: mgmt-waf-access-log"
}

variable "env_access_log_bucket" {
  type        = "string"
  default     = "env-waf-access-log"
  description = "Name of S3 bucket for env account ALB access logs. Default: env-waf-access-log"
}

data "aws_elb_service_account" "main" {}
