variable "name" {
  type = "string"
}

variable "email" {
  type = "string"
}

variable "iam_role_name" {
  default = "OrganizationAccountAccessRole"
}
