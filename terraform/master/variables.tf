variable "bucket" {
  type = "string"
}

variable "s3_bucket_monitoring_account" {
  type = "string"
  default = "grace_monitoring"
}

variable "s3_bucket_key_threatfeed" {
  type = "string"
  default = "guardduty/threatfeed.txt"
}

variable "transit_vpc_key_name" {
  default     = "Cisco-CSR-Transit-VPC-Grace"
  description = "EC2 key pair name for logging in to the Cisco CSR instances"
}
