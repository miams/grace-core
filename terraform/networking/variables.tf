variable "mgmt_account_id" {}

variable "prod_account_id" {}

variable "mgmt_region" {
  default = "us-east-1"
}

variable "prod_region" {
  default = "us-east-1"
}

variable "default_region" {
  default = "us-east-1"
}

variable "prod_az_1" {
  default = "us-east-1b"
}

variable "prod_az_2" {
  default = "us-east-1c"
}

variable "mgmt_az_1" {
  default = "us-east-1d"
}

variable "mgmt_az_2" {
  default = "us-east-1f"
}

variable "iam_role_name" {
  default = "OrganizationAccountAccessRole"
}

variable "mgmt_customer_gateway_ip" {
  default = "172.0.0.1"
}

variable "prod_customer_gateway_ip" {
  default = "172.0.0.2"
}

variable "mgmt_access_log_bucket" {
  default = "mgmt-waf-access-log"
}

variable "prod_access_log_bucket" {
  default = "prod-waf-access-log"
}
