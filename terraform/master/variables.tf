variable "bucket" {
  type = "string"
}

variable "transit_vpc_account_id" {
  type        = "string"
  description = "The account ID where the Transit VPC should live"
}

variable "transit_vpc_cidr" {
  default     = "100.64.127.224/27"
  description = "Default value provided by AWS"
}

variable "transit_vpc_subnet_1_cidr" {
  default     = "100.64.127.224/28"
  description = "Default value provided by AWS"
}

variable "transit_vpc_subnet_2_cidr" {
  default     = "100.64.127.240/28"
  description = "Default value provided by AWS"
}

variable "transit_vpc_key_name" {
  default     = "Cisco-CSR-Transit-VPC-Grace"
  description = "EC2 key pair name for logging in to the Cisco CSR instances"
}
