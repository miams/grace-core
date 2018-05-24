module "vpc_env" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "= 1.17.0"

  providers = {
    aws = "aws.env"
  }

  azs                  = ["${var.env_az_1}", "${var.env_az_2}"]
  cidr                 = "${var.env_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  name                 = "ENV-devsecops-networking-test"
  public_subnets       = ["${cidrsubnet(var.env_cidr, 8, 1)}", "${cidrsubnet(var.env_cidr, 8, 2)}"]
  private_subnets      = ["${cidrsubnet(var.env_cidr, 8, 3)}", "${cidrsubnet(var.env_cidr, 8, 4)}"]

  tags = {
    Terraform = "true"
  }
}

module "env_spoke" {
  source = "../spoke"

  providers = {
    aws = "aws.env"
  }

  num_gateway_subnets = "2"
  gateway_subnet_ids  = "${module.vpc_env.private_subnets}"
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

# Optional Base Security Groups
resource "aws_security_group" "env_ingress_https_sg" {
  # Conditionally create this resource if the value is true
  count = "${var.vpc_env_set_default_ingress_https_rule == "true" ? 1 : 0}"

  name        = "${var.vpc_env_ingress_https_sg_name}"
  description = "Tenant Security Group for HTTPS from all sources (ingress)"

  providers = {
    aws = "aws.env"
  }

  vpc_id = "${module.vpc_env.vpc_id}"

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = "${var.vpc_env_ingress_https_cidr}"
  }
}

resource "aws_security_group" "env_ec2_management_sg" {
  # Conditionally create this resource if the value is true
  count = "${var.vpc_env_set_default_ingress_rdp_ssh_rule == "true" ? 1 : 0}"

  name        = "${var.vpc_env_ec2_management_sg_name}"
  description = "Tenant Security Group for managing instances"

  providers = {
    aws = "aws.env"
  }

  vpc_id = "${module.vpc_env.vpc_id}"

  ingress {
    from_port   = "${var.env_sg_ingress_rdp_port}"
    to_port     = "${var.env_sg_ingress_rdp_port}"
    protocol    = "${var.env_sg_ingress_rdp_protocol}"
    cidr_blocks = "${var.env_sg_ingress_rdp_cidrs}"
  }

  ingress {
    from_port   = "${var.env_sg_ingress_ssh_port}"
    to_port     = "${var.env_sg_ingress_ssh_port}"
    protocol    = "${var.env_sg_ingress_ssh_protocol}"
    cidr_blocks = "${var.env_sg_ingress_ssh_cidrs}"
  }

  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

resource "aws_security_group" "env_ec2_egress_on_prem" {
  count = "${var.vpc_env_set_default_egress_rule == "true" ? 1 : 0}"

  name        = "${var.vpc_env_ec2_egress_on_prem_sg_name}"
  description = "Tenant security group for egress to on-prem"

  providers = {
    aws = "aws.env"
  }

  vpc_id = "${module.vpc_env.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.env_ec2_egress_on_prem_all_traffic_cidrs}"
  }

  egress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = "${var.env_ec2_egress_on_prem_smtp_cidrs}"
  }
}

resource "aws_network_acl" "env_public_nacl" {
  # TODO: Possible problem here with count as a conditional, need to test.
  count = "${var.vpc_env_set_default_public_nacl == "true" ? 1 : 0}"

  vpc_id     = "${module.vpc_env.vpc_id}"
  subnet_ids = "${module.vpc_env.public_subnets}"

  providers = {
    aws = "aws.env"
  }

  # TODO: Think of a crafty way to loop through these and create them from variables
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_network_acl" "env_private_nacl" {
  # TODO: Possible problem here with count as a conditional, need to test.
  count = "${var.vpc_env_set_default_private_nacl == "true" ? 1 : 0}"

  vpc_id     = "${module.vpc_env.vpc_id}"
  subnet_ids = "${module.vpc_env.private_subnets}"

  providers = {
    aws = "aws.env"
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
