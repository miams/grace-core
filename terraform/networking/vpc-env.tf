module "vpc_env" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"

  providers = {
    aws = "aws.env"
  }

  azs                  = ["${var.env_az_1}", "${var.env_az_2}"]
  cidr                 = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  name                 = "ENV-devsecops-networking-test"
  public_subnets       = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets      = ["10.1.3.0/24", "10.1.4.0/24"]

  tags = {
    Terraform = "true"
  }
}

module "env_spoke" {
  source = "../spoke"

  providers = {
    aws = "aws.env"
  }

  gateway_subnet_id = "${module.vpc_env.private_subnets[0]}"
}

resource "aws_vpc_peering_connection" "peer_vpc_env" {
  vpc_id      = "${module.vpc_env.vpc_id}"
  peer_vpc_id = "${module.vpc_mgmt.vpc_id}"
  peer_region = "${var.mgmt_region}"

  # Because the VPCs are currently in the same account, will set auto_accept to true. When VPC's are in separate accounts, uncomment the next two lines.
  peer_owner_id = "${data.aws_caller_identity.mgmt.account_id}"
  auto_accept   = false

  # auto_accept   = true
  provider = "aws.env"

  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }


  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }

  tags {
    Side = "Requester"
  }
}
