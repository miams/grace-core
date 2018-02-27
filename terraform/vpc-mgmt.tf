module "vpc_mgmt" {
  source = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"
  providers = {
    aws = "aws.mgmt"
  }

  azs = ["${var.mgmt_az_1}", "${var.mgmt_az_2}"]
  cidr = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
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
  ip_address = "${var.mgmt_customer_gateway_ip}"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "mgmt_vpn_connection" {
  vpn_gateway_id      = "${aws_vpn_gateway.mgmt_vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.mgmt_customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false
}

# The accepter resources below are commented out because currently, these VPCs are all in the same account. If the VPC's are in separate accounts, then enable these resources and look at the peer connections in the other files to make sure they are set to auto_accept = false.
#
resource "aws_vpc_peering_connection_accepter" "peer_vpc_dev" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer_vpc_dev.id}"
  auto_accept               = true
  tags {
    Side = "Accepter for dev"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_vpc_prod" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer_vpc_prod.id}"
  auto_accept               = true
  tags {
    Side = "Accepter for prod"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_vpc_staging" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer_vpc_staging.id}"
  auto_accept               = true
  tags {
    Side = "Accepter for staging"
  }
}