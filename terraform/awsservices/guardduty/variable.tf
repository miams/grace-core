variable "s3_bucket_name" {
  description = "Bucket Name For Consuming ThreatIntel list"
  default = ""
}

variable "s3_bucket_name_key" {
  description = "Bucket Name key For Consuming ThreatIntel list"
  default = ""
}

variable "aws_guardduty_member_account_number" {
  description = "Account of member account to be added to GuardDuty"
  default = "123456789012"
}

variable "aws_guardduty_member_account_email" {
  description = "Email address of member account to be added to GuardDuty"
  default = "required@example.com"
}
