variable "name" {
  type = "string"
}

variable "email" {
  type = "string"
}

variable "iam_role_name" {
  default     = "OrganizationAccountAccessRole"
  description = "Role used for cross-account access from the master to the member"
}

variable "create_iam_roles" {
  default     = "true"
  description = "Boolean to define whether or not to create the IAM roles in this account."
}

# Change default value to true for production code.
variable "enable_member_guardduty" {
  description = "Enable guardduty and integrate with monitoring account true/false"
  default = "false"
}

# Modify python script to pass it during module call
variable "guardduty_master_detector_id" {
  description = "Enable guardduty and integrate with monitoring account true/false"
  default = "84b2552af47e59064e37e7100cd925fc"
}


variable "authlanding_prod_account_id" {
  description = "AWS Account ID of the Authlanding account"
}
