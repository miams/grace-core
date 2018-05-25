provider "aws" {
  alias = "netops"

  assume_role {
    role_arn = "arn:aws:iam::${var.transit_vpc_account_id}:role/OrganizationAccountAccessRole"
  }
}

resource "aws_cloudformation_stack" "transit_vpc" {
  provider = "aws.netops"

  name         = "Grace-Transit-VPC-Cisco-CSR"
  capabilities = ["CAPABILITY_IAM"]

  # https://docs.aws.amazon.com/solutions/latest/cisco-based-transit-vpc/templates.html
  template_body = "${file("${path.module}/files/transit_vpc_template.json")}"

  parameters {
    AccountId  = "${module.tenant_1_dev.account_id}"
    KeyName    = "Cisco-CSR-Transit-VPC-Grace"
    PubSubnet1 = "${var.transit_vpc_subnet_1_cidr}"
    PubSubnet2 = "${var.transit_vpc_subnet_2_cidr}"
    VpcCidr    = "${var.transit_vpc_cidr}"
  }

  lifecycle {
    prevent_destroy = true
  }
}
