module "vpc_dev" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"
  providers = {
    aws = "aws.dev"
  }

  azs = ["${var.dev_az_1}", "${var.dev_az_2}"]
  cidr = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
  name = "DEV-devsecops-networking-test"
  public_subnets = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnets = ["10.2.3.0/24", "10.2.4.0/24"]
  
  tags = {
      Terraform = "true"
      Environment = "Dev"
      }
}

resource "aws_vpn_gateway" "dev_vpn_gateway" {
  vpc_id = "${module.vpc_dev.vpc_id}"
  provider = "aws.dev"
}

resource "aws_customer_gateway" "dev_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "${var.dev_customer_gateway_ip}"
  type       = "ipsec.1"
  provider = "aws.dev"
}

resource "aws_vpn_connection" "dev_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.dev_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.dev_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
  provider = "aws.dev"
}

resource "aws_vpc_peering_connection" "peer_vpc_dev" {
  vpc_id        = "${module.vpc_dev.vpc_id}"
  peer_vpc_id   = "${module.vpc_mgmt.vpc_id}"
  peer_region = "${var.mgmt_region}"
  # Because the VPCs are currently in the same account, will set auto_accept to true. When VPC's are in separate accounts, uncomment the next two lines.
  peer_owner_id = "${data.aws_caller_identity.mgmt.account_id}"
  auto_accept   = false
  # auto_accept = true
  provider = "aws.dev"

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }

  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }

  tags {
    Side = "Requester-Dev"
  }
}