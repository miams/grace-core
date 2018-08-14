# Tenant file for gracesharedservices, autogenerated by python tool.
provider "aws" {
  alias = "sharedservices"

  assume_role {
    role_arn = "arn:aws:iam::${module.tenant_gracesharedservices_prod.account_id}:role/OrganizationAccountAccessRole"
  }
}

data "aws_ssm_parameter" "gracesharedservices_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "gracesharedservices-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "gracesharedservices_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "gracesharedservices-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "gracesharedservices_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "gracesharedservices-tenant-viewonly-iam-role-list"
}

locals {
  gracesharedservices_tenant_admin_iam_role_list = ["${split(",", data.aws_ssm_parameter.gracesharedservices_tenant_admin_iam_role_list.value)}"]
  gracesharedservices_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.gracesharedservices_tenant_poweruser_iam_role_list.value)}"]
  gracesharedservices_tenant_viewonly_iam_role_list = ["${split(",", data.aws_ssm_parameter.gracesharedservices_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_gracesharedservices_prod" {
  source = "../member_account"

  name = "tenant_gracesharedservices_prod"
  email = "jasong.miller+sharedservicesprod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.gracesharedservices_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.gracesharedservices_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.gracesharedservices_tenant_viewonly_iam_role_list}"]
  enable_member_guardduty = "true"
  guardduty_master_detector_id = "${aws_guardduty_detector.aws_guardduty_master.id}"
}

module "tenant_gracesharedservices_mgmt" {
  source = "../member_account"

  name = "tenant_gracesharedservices_mgmt"
  email = "jasong.miller+sharedservicesmgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.gracesharedservices_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.gracesharedservices_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.gracesharedservices_tenant_viewonly_iam_role_list}"]
  enable_member_guardduty = "true"
  guardduty_master_detector_id = "${aws_guardduty_detector.aws_guardduty_master.id}"
}

module "gracesharedservices_budget" {
  source = "../budget"

  name = "gracesharedservices"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+sharedservicesbudget@gsa.gov"
    }
  ]

  account_ids = [
    "${module.tenant_gracesharedservices_prod.account_id}",
    "${module.tenant_gracesharedservices_mgmt.account_id}",
  ]
}

# This account has a unique AMI builder user. Note that because there's no explicit secret store
# for GRACE to store secrets for IAM access, you will have to create an access key yourself in
# the web console (as of August 6, 2018)

resource "aws_iam_user" "packer_builder" {
  provider = "aws.sharedservices"
  name = "packer_builder"
}

resource "aws_iam_user_policy" "packer_builder_iam_policy" {
  provider = "aws.sharedservices"
  name = "packer_builder_ami_policy"
  user = "${aws_iam_user.packer_builder.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObjectAcl",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:GetBucketAcl",
                "s3:GetBucketPolicy"
            ],
            "Resource": [
                "arn:aws:s3:::grace-tenant-info",
                "arn:aws:s3:::grace-tenant-info/tenant-info/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DeregisterImage",
                "ec2:DeleteSnapshot",
                "ec2:DescribeInstances",
                "ec2:CreateKeyPair",
                "ec2:DescribeRegions",
                "ec2:CreateImage",
                "ec2:CopyImage",
                "ec2:ModifyImageAttribute",
                "ec2:DescribeSnapshots",
                "ec2:DeleteVolume",
                "ec2:ModifySnapshotAttribute",
                "ec2:CreateSecurityGroup",
                "ec2:DescribeVolumes",
                "ec2:CreateSnapshot",
                "s3:HeadBucket",
                "ec2:ModifyInstanceAttribute",
                "ec2:DetachVolume",
                "ec2:TerminateInstances",
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateVolume",
                "ec2:DescribeImages",
                "ec2:GetPasswordData",
                "s3:ListAllMyBuckets",
                "ec2:DescribeImageAttribute",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeSubnets",
                "ec2:DeleteKeyPair"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# IAM role permission section - have to give sts-assume-role permission to users to allow them to switch to the roles.

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_gracesharedservices_prod" {
  provider = "aws.authlanding"
  name = "gracesharedservices_prod_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this gracesharedservices_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_gracesharedservices_prod.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_gracesharedservices_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.gracesharedservices_tenant_admin_iam_role_list)}"
  user = "${local.gracesharedservices_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_gracesharedservices_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_gracesharedservices_prod" {
  provider = "aws.authlanding"
  name = "gracesharedservices_prod_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this gracesharedservices_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_gracesharedservices_prod.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_gracesharedservices_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.gracesharedservices_tenant_poweruser_iam_role_list)}"
  user = "${local.gracesharedservices_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_gracesharedservices_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_gracesharedservices_prod" {
  provider = "aws.authlanding"
  name = "gracesharedservices_prod_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this gracesharedservices_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_gracesharedservices_prod.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_gracesharedservices_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.gracesharedservices_tenant_viewonly_iam_role_list)}"
  user = "${local.gracesharedservices_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_gracesharedservices_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_gracesharedservices_mgmt" {
  provider = "aws.authlanding"
  name = "gracesharedservices_mgmt_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this gracesharedservices_mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_gracesharedservices_mgmt.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_gracesharedservices_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.gracesharedservices_tenant_admin_iam_role_list)}"
  user = "${local.gracesharedservices_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_gracesharedservices_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_gracesharedservices_mgmt" {
  provider = "aws.authlanding"
  name = "gracesharedservices_mgmt_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this gracesharedservices_mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_gracesharedservices_mgmt.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_gracesharedservices_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.gracesharedservices_tenant_poweruser_iam_role_list)}"
  user = "${local.gracesharedservices_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_gracesharedservices_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_gracesharedservices_mgmt" {
  provider = "aws.authlanding"
  name = "gracesharedservices_mgmt_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this gracesharedservices_mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_gracesharedservices_mgmt.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_gracesharedservices_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.gracesharedservices_tenant_viewonly_iam_role_list)}"
  user = "${local.gracesharedservices_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_gracesharedservices_mgmt.arn}"
}

# This tenant also has a lambda function that will query the tenant accounts in a sub OU to get the AWS accounts IDs.
# 08/08/18 by Jason Miller - jasong.miller@gsa.gov

data "template_file" "tenant_info_bucket_kms_key_policy" {
  template = "${file("${path.module}/files/tenant-info-bucket-kms-key-policy.json")}"
    vars = {
      shared_services_prod_account_id = "${module.tenant_gracesharedservices_prod.account_id}"
      shared_services_mgmt_account_id = "${module.tenant_gracesharedservices_mgmt.account_id}"
      packer_builder_user_arn = "${aws_iam_user.packer_builder.arn}"
      tenant_account_lister_role_arn = "${aws_iam_role.tenant_account_lister_role.arn}"
  }
}

resource "aws_kms_key" "grace-tenant-info-bucket-kms-key" {
  description             = "This key is used to encrypt bucket objects in the grace-tenant-info bucket"
  policy = "${data.template_file.tenant_info_bucket_kms_key_policy.rendered}"
}

resource "aws_s3_bucket" "tenant_info_bucket" {
  bucket = "grace-tenant-info"
  acl    = "private"
  policy = "${data.template_file.tenant_info_bucket_policy.rendered}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.grace-tenant-info-bucket-kms-key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Purpose = "Stores information about the tenant subaccount IDs for other grace-core elements to use."
  }
}

data "template_file" "tenant_info_bucket_policy" {
    template = "${file("${path.module}/files/tenant-info-bucket-policy.json")}"
    vars = {
      shared_services_prod_account_id = "${module.tenant_gracesharedservices_prod.account_id}"
      shared_services_mgmt_account_id = "${module.tenant_gracesharedservices_mgmt.account_id}"
    }
}

resource "aws_iam_role" "tenant_account_lister_role" {
  name = "tenant-account-lister-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# TODO: Tighten up this policy
resource "aws_iam_role_policy" "tenant_account_lister_role_policy" {
  name = "tenant_account_lister_role_policy"
  role = "${aws_iam_role.tenant_account_lister_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "lambda_tenant_account_lister_file" {
  type        = "zip"
  source_file = "${path.module}/files/tenant-account-lister.py"
  output_path = "${path.module}/files/tenant-account-lister.py.zip"
}

resource "aws_lambda_function" "lambda_tenant_account_lister_function" {
  filename      = "${path.module}/files/tenant-account-lister.py.zip"
  function_name = "tenant-account-lister"
  role          = "${aws_iam_role.tenant_account_lister_role.arn}"
  handler       = "tenant-account-lister.lambda_handler"
  runtime       = "python3.6"
}

resource "aws_cloudwatch_event_rule" "tenant_account_lister_event" {
  name                = "tenant-account-lister-run-hourly"
  description         = "Runs tenant account lister at the top of every hour"
  schedule_expression = "cron(1 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_backup_function_event" {
  rule      = "${aws_cloudwatch_event_rule.tenant_account_lister_event.name}"
  target_id = "lambda_tenant_account_lister_function"
  arn       = "${aws_lambda_function.lambda_tenant_account_lister_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_tenant_account_lister_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_tenant_account_lister_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.tenant_account_lister_event.arn}"
}

# End tenant_account_lister lambda function resources