# Tenant file for gracesharedservices, autogenerated by python tool.
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

# This account has a unique AMI builder user

resource "aws_iam_user" "packer_builder" {
  name = "packer_builder"
}

resource "aws_iam_user_policy" "packer_builder_iam_policy" {
  name = "packer_builder_ami_policy"
  user = "${aws_iam_user.packer_builder.name}"

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

