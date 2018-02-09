module "vpc_prod" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.11.0"
  providers = {
    aws = "aws.west1"
  }

  azs = ["us-west-1a", "us-west-1b"]
  cidr = "11.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
  name = "PROD-devsecops-networking-test"
  public_subnets = ["11.0.1.0/24", "11.0.2.0/24"]
  private_subnets = ["11.0.3.0/24", "11.0.4.0/24"]
  
  tags = {
      Terraform = "true"
      Environment = "Prod"
      }
}

resource "aws_vpn_gateway" "prod_vpn_gateway" {
  vpc_id = "${module.vpc_prod.vpc_id}"
}

resource "aws_customer_gateway" "prod_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "172.0.0.2"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "prod_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.prod_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.prod_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
}

resource "aws_vpc_peering_connection" "peer_vpc_prod" {
  vpc_id        = "${module.vpc_prod.vpc_id}"
  peer_vpc_id   = "${module.vpc_mgmt.vpc_id}"
  peer_owner_id = "${data.aws_caller_identity.west1.account_id}"
  # peer_region   = "us-west-1"
  auto_accept   = false

  tags {
    Side = "Requester-Prod"
  }
}