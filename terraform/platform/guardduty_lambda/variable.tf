variable "deploy_guardduty_threatfeed_lambda" {
  description = "Deploys guardduty threadfeed lambda"
  default = "false"
}

variable "threatfeed_days_requested" {
  description = "Days of threatfeed to be downloaded"
  default = "7"
}

variable "threatfeed_output_bucket" {
  description = "S3 bucket for placing threatfeed file"
  default = ""
}


variable "threatfeed_priv_key" {
  description = "Info to download threatfeed"
  default = ""
}

variable "threatfeed_pub_key" {
  description = "Info to download threatfeed"
  default = ""
}
