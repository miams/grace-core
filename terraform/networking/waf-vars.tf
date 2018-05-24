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

variable "aws_alb_service_account" {
  type        = "string"
  default     = "127311923021"
  description = "AWS account ID for ALB access to access log S3 bucket. Default: 127311923021 (us-east-1)"
}
