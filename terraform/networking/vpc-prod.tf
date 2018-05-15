module "vpc_prod" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"
  providers = {
    aws = "aws.prod"
  }

  azs = ["${var.prod_az_1}", "${var.prod_az_2}"]
  cidr = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
  name = "PROD-devsecops-networking-test"
  public_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.3.0/24", "10.1.4.0/24"]
  
  tags = {
      Terraform = "true"
      Environment = "Prod"
      }
}

resource "aws_vpn_gateway" "prod_vpn_gateway" {
  vpc_id = "${module.vpc_prod.vpc_id}"
  provider = "aws.prod"
}

resource "aws_customer_gateway" "prod_customer_gateway" {
  bgp_asn    = 65000
  ip_address = "${var.prod_customer_gateway_ip}"
  type       = "ipsec.1"
  provider = "aws.prod"
}

resource "aws_vpn_connection" "prod_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.prod_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.prod_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
  provider = "aws.prod"
}

resource "aws_vpc_peering_connection" "peer_vpc_prod" {
  vpc_id        = "${module.vpc_prod.vpc_id}"
  peer_vpc_id   = "${module.vpc_mgmt.vpc_id}"
  peer_region = "${var.mgmt_region}"
  # Because the VPCs are currently in the same account, will set auto_accept to true. When VPC's are in separate accounts, uncomment the next two lines.
  peer_owner_id = "${data.aws_caller_identity.mgmt.account_id}"
  auto_accept   = false
  # auto_accept   = true
  provider = "aws.prod"

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }

  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }

  tags {
    Side = "Requester-Prod"
  }
}