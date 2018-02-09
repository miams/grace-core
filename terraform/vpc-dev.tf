module "vpc_dev" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.11.0"
  providers = {
    aws = "aws.east1"
  }

  azs = ["us-east-1b", "us-east-1c"]
  cidr = "12.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
  name = "DEV-devsecops-networking-test"
  public_subnets = ["12.0.1.0/24", "12.0.2.0/24"]
  private_subnets = ["12.0.3.0/24", "12.0.4.0/24"]
  
  tags = {
      Terraform = "true"
      Environment = "Dev"
      }
}

resource "aws_vpn_gateway" "dev_vpn_gateway" {
  vpc_id = "${module.vpc_dev.vpc_id}"
}

resource "aws_customer_gateway" "dev_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "172.0.0.4"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "dev_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.dev_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.dev_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
}

resource "aws_vpc_peering_connection" "peer_vpc_dev" {
  vpc_id        = "${module.vpc_dev.vpc_id}"
  peer_vpc_id   = "${module.vpc_mgmt.vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.east1.account_id}"
  # peer_region   = "us-east-1"
  auto_accept   = false

  tags {
    Side = "Requester-Dev"
  }
}