variable "mgmt_account_id" {}

variable "dev_account_id" {}

variable "prod_account_id" {}

variable "staging_account_id" {}

variable "mgmt_region" {
  default = "us-east-1"
}

variable "dev_region" {
  default = "us-east-1"
}

variable "prod_region" {
  default = "us-east-1"
}

variable "staging_region" {
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

variable "dev_az_1" {
  default = "us-east-1a"
}

variable "dev_az_2" {
  default = "us-east-1d"
}

variable "staging_az_1" {
  default = "us-east-1c"
}

variable "staging_az_2" {
  default = "us-east-1e"
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

variable "staging_customer_gateway_ip" {
  default = "172.0.0.3"
}

variable "dev_customer_gateway_ip" {
  default = "172.0.0.4"
}

variable "mgmt_access_log_bucket" {
  default = "mgmt-waf-access-log"
}

variable "dev_access_log_bucket" {
  default = "dev-waf-access-log"
}

variable "prod_access_log_bucket" {
  default = "prod-waf-access-log"
}

variable "staging_access_log_bucket" {
  default = "staging-waf-access-log"
}
