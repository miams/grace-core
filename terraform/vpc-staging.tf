module "vpc_staging" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"
  providers = {
    aws = "aws.west2"
  }

  azs = ["us-west-2a", "us-west-2b"]
  cidr = "10.3.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
  name = "STAGING-devsecops-networking-test"
  public_subnets = ["10.3.1.0/24", "10.3.2.0/24"]
  private_subnets = ["10.3.3.0/24", "10.3.4.0/24"]
  
  tags = {
      Terraform = "true"
      Environment = "Staging"
      }
}

resource "aws_vpn_gateway" "staging_vpn_gateway" {
  vpc_id = "${module.vpc_staging.vpc_id}"
  provider = "aws.west2"
}

resource "aws_customer_gateway" "staging_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "${var.staging_customer_gateway_ip}"
  type       = "ipsec.1"
  provider = "aws.west2"
}

resource "aws_vpn_connection" "staging_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.staging_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.staging_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
  provider = "aws.west2"
}

resource "aws_vpc_peering_connection" "peer_vpc_staging" {
  vpc_id        = "${module.vpc_staging.vpc_id}"
  peer_vpc_id   = "${module.vpc_mgmt.vpc_id}"
  peer_region = "us-east-2"
  # Because the VPCs are currently in the same account, will set auto_accept to true. When VPC's are in separate accounts, uncomment the next two lines.
  # peer_owner_id = "${data.aws_caller_identity.east2.account_id}"
  auto_accept   = false
  # auto_accept = true
  provider = "aws.west2"

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }

  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }

  tags {
    Side = "Requester-Staging"
  }
}