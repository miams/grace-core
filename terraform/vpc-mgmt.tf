module "vpc_mgmt" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.11.0"

  azs = ["us-east-1b", "us-east-1d"]
  cidr = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = true
  name = "MGMT-devsecops-networking-test"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  
  tags = {
      Terraform = "true"
      Environment = "Management"
      }
}

resource "aws_vpn_gateway" "mgmt_vpn_gateway" {
  vpc_id = "${module.vpc_mgmt.vpc_id}"
}

resource "aws_customer_gateway" "mgmt_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "172.0.0.1"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "mgmt_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.mgmt_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.mgmt_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
}