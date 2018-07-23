locals {
  spoke_account_arns = [
    "arn:aws:iam::${data.aws_caller_identity.master.account_id}:root",
    "${module.devsecops_test_3.root_arn}",
    "${module.tenant_1_dev.root_arn}",
    "${module.tenant_1_mgmt.root_arn}",
    "${module.tenant_1_prod.root_arn}",
    "${module.tenant_1_staging.root_arn}",
    "${module.tenant_spoketest_prod.root_arn}",
    "${module.tenant_spoketest_mgmt.root_arn}",
    "${module.tenant_spoketest_dev.root_arn}",
    "${module.tenant_demotest14_staging.root_arn}",
    "${module.tenant_demotest14_prod.root_arn}",
    "${module.tenant_demotest14_mgmt.root_arn}",
    "${module.tenant_demotest14_dev.root_arn}",
  ]
}

# corresponds to
# https://docs.aws.amazon.com/solutions/latest/cisco-based-transit-vpc/step2.html

# The account ID where the Transit VPC should live
data "aws_ssm_parameter" "transit_vpc_account_id" {
  name = "transit_vpc_account_id"
}

data "aws_ssm_parameter" "transit_vpc_cidr" {
  name = "transit_vpc_cidr"
}

data "aws_ssm_parameter" "transit_vpc_subnet_1_cidr" {
  name = "transit_vpc_subnet_1_cidr"
}

data "aws_ssm_parameter" "transit_vpc_subnet_2_cidr" {
  name = "transit_vpc_subnet_2_cidr"
}

# change the value in ssm parameter during production deployment to deploy CSR with higher throughput rating
data "aws_ssm_parameter" "transit_vpc_csr_throughput" {
  name = "transit_vpc_csr_throughput"
}

# not using member_account module since the NetOps account isn't part of the SAIC AWS Organization
provider "aws" {
  alias = "netops"

  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.transit_vpc_account_id.value}:role/OrganizationAccountAccessRole"
  }
}

resource "aws_cloudformation_stack" "transit_vpc" {
  provider = "aws.netops"

  name         = "Grace-Transit-VPC-Cisco-CSR"
  capabilities = ["CAPABILITY_IAM"]

  # https://docs.aws.amazon.com/solutions/latest/cisco-based-transit-vpc/templates.html
  template_body = "${file("${path.module}/files/transit-vpc-primary-account.template.json")}"

  parameters {
    KeyName    = "${var.transit_vpc_key_name}"
    PubSubnet1 = "${data.aws_ssm_parameter.transit_vpc_subnet_1_cidr.value}"
    PubSubnet2 = "${data.aws_ssm_parameter.transit_vpc_subnet_2_cidr.value}"
    VpcCidr    = "${data.aws_ssm_parameter.transit_vpc_cidr.value}"
    CSRType    = "${data.aws_ssm_parameter.transit_vpc_csr_throughput.value}"
  }

  lifecycle {
    # since the CSR needs to be manually connected to the GSA network, be careful not to destroy it
    prevent_destroy = true
  }
}

# This will override the bucket policy created by the CloudFormation stack. Needed because only one account ID can be passed in as a parameter.
# https://docs.aws.amazon.com/solutions/latest/cisco-based-transit-vpc/appendix-c.html
resource "aws_s3_bucket_policy" "transit_vpc" {
  provider = "aws.netops"

  bucket = "${aws_cloudformation_stack.transit_vpc.outputs["ConfigS3Bucket"]}"

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(local.spoke_account_arns)}
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${aws_cloudformation_stack.transit_vpc.outputs["ConfigS3Bucket"]}/${aws_cloudformation_stack.transit_vpc.outputs["BucketPrefix"]}*"
        }
    ]
}
POLICY
}
