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
