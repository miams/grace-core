variable "bucket" {
  type = "string"
}

variable "transit_vpc_key_name" {
  default     = "Cisco-CSR-Transit-VPC-Grace"
  description = "EC2 key pair name for logging in to the Cisco CSR instances"
}
