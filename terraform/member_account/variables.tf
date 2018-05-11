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
