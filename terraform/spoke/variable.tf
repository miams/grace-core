variable "default_region" {
  default = "us-east-1"
}

variable "profile" {
  description = "Enter AWS Profile youwant to use:::"
}

variable "TransitVpcBucketName" {
  default = "grace-transit-vpc-cisco-csr-vpnconfigs3bucket-8qip7j4p30dd"
}

variable "TransitVpcBucketPrefix" {
  default = "vpnconfigs/"
}
