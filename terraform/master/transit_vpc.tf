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
    # arbitrary, since it will be overwritten below
    AccountId = "${module.tenant_1_dev.account_id}"

    KeyName    = "Cisco-CSR-Transit-VPC-Grace"
    PubSubnet1 = "${var.transit_vpc_subnet_1_cidr}"
    PubSubnet2 = "${var.transit_vpc_subnet_2_cidr}"
    VpcCidr    = "${var.transit_vpc_cidr}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# This will override the bucket policy created by the CloudFormation stack. Needed because only one account ID can be passed in as a parameter.
# https://docs.aws.amazon.com/solutions/latest/cisco-based-transit-vpc/appendix-c.html
resource "aws_s3_bucket_policy" "transit_vpc" {
  provider = "aws.netops"

  bucket = "${aws_cloudformation_stack.transit_vpc.outputs.ConfigS3Bucket}"

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${module.tenant_1_staging.account_id}:root",
                    "arn:aws:iam::${module.devsecops_test_3.account_id}:root",
                    "arn:aws:iam::${module.tenant_1_mgmt.account_id}:root",
                    "arn:aws:iam::${module.tenant_1_prod.account_id}:root",
                    "arn:aws:iam::${module.tenant_1_dev.account_id}:root",
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::${aws_cloudformation_stack.transit_vpc.outputs.ConfigS3Bucket}/${aws_cloudformation_stack.transit_vpc.outputs.BucketPrefix}*"
        }
    ]
}
POLICY
}
