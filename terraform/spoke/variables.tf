variable "gateway_subnet_ids" {
  type        = "list"
  description = "IDs of subnets to attach the route table to. Must all be in the same VPC."
}

variable "TransitVpcBucketName" {
  default = "grace-transit-vpc-cisco-csr-vpnconfigs3bucket-8qip7j4p30dd"
}

variable "TransitVpcBucketPrefix" {
  default = "vpnconfigs/"
}
