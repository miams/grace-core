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

variable "authlanding_prod_account_id" {
  description = "AWS Account ID of the Authlanding account"
}
