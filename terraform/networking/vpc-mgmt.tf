module "vpc_mgmt" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"

  providers = {
    aws = "aws.mgmt"
  }

  azs                  = ["${var.mgmt_az_1}", "${var.mgmt_az_2}"]
  cidr                 = "${var.mgmt_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  name                 = "MGMT-devsecops-networking-test"
  public_subnets       = ["${cidrsubnet(var.mgmt_cidr, 8, 1)}", "${cidrsubnet(var.mgmt_cidr, 8, 2)}"]
  private_subnets      = ["${cidrsubnet(var.mgmt_cidr, 8, 3)}", "${cidrsubnet(var.mgmt_cidr, 8, 4)}"]

  tags = {
    Terraform   = "true"
    Environment = "Management"
  }
}

module "mgmt_spoke" {
  source = "../spoke"

  providers = {
    aws = "aws.mgmt"
  }

  gateway_subnet_id = "${module.vpc_mgmt.private_subnets[0]}"
}

# The accepter resources below are commented out because currently, these VPCs are all in the same account. If the VPC's are in separate accounts, then enable these resources and look at the peer connections in the other files to make sure they are set to auto_accept = false.
#

resource "aws_vpc_peering_connection_accepter" "peer_vpc_env" {
  vpc_peering_connection_id = "${aws_vpc_peering_connection.peer_vpc_env.id}"
  auto_accept               = true

  tags {
    Side = "Accepter for the environment"
  }
}
