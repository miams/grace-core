# Tenant file for demotest15, autogenerated by python tool.
data "aws_ssm_parameter" "demotest15_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest15-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "demotest15_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest15-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "demotest15_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest15-tenant-viewonly-iam-role-list"
}

locals {
  demotest15_tenant_admin_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest15_tenant_admin_iam_role_list.value)}"]
  demotest15_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest15_tenant_poweruser_iam_role_list.value)}"]
  demotest15_tenant_viewonly_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest15_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_demotest15_prod" {
  source = "../member_account"

  name = "tenant_demotest15_prod"
  email = "jasong.miller+demotest15prod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest15_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest15_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest15_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest15_mgmt" {
  source = "../member_account"

  name = "tenant_demotest15_mgmt"
  email = "jasong.miller+demotest15mgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest15_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest15_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest15_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest15_staging" {
  source = "../member_account"

  name = "tenant_demotest15_staging"
  email = "jasong.miller+demotest15staging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest15_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest15_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest15_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest15_dev" {
  source = "../member_account"

  name = "tenant_demotest15_dev"
  email = "jasong.miller+demotest15dev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest15_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest15_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest15_tenant_viewonly_iam_role_list}"]
}

module "demotest15_budget" {
  source = "../budget"

  name = "demotest15"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+demotest15budget@gsa.gov"
    }
  ]

  account_ids = [
    "${module.tenant_demotest15_prod.account_id}",
    "${module.tenant_demotest15_mgmt.account_id}",
    "${module.tenant_demotest15_staging.account_id}",
    "${module.tenant_demotest15_dev.account_id}",
  ]
}

# IAM role permission section - have to give sts-assume-role permission to users to allow them to switch to the roles.

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest15_prod" {
  provider = "aws.authlanding"
  name = "demotest15_prod_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest15_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_prod.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest15_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_admin_iam_role_list)}"
  user = "${local.demotest15_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest15_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest15_prod" {
  provider = "aws.authlanding"
  name = "demotest15_prod_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest15_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_prod.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest15_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest15_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest15_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest15_prod" {
  provider = "aws.authlanding"
  name = "demotest15_prod_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest15_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_prod.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest15_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest15_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest15_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest15_mgmt" {
  provider = "aws.authlanding"
  name = "demotest15_mgmt_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest15_mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_mgmt.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest15_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_admin_iam_role_list)}"
  user = "${local.demotest15_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest15_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest15_mgmt" {
  provider = "aws.authlanding"
  name = "demotest15_mgmt_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest15_mgmtaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_mgmt.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest15_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest15_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest15_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest15_mgmt" {
  provider = "aws.authlanding"
  name = "demotest15_mgmt_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest15_mgmtaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_mgmt.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest15_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest15_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest15_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest15_staging" {
  provider = "aws.authlanding"
  name = "demotest15_staging_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest15_staging account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_staging.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest15_staging_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_admin_iam_role_list)}"
  user = "${local.demotest15_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest15_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest15_staging" {
  provider = "aws.authlanding"
  name = "demotest15_staging_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest15_stagingaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_staging.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest15_staging_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest15_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest15_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest15_staging" {
  provider = "aws.authlanding"
  name = "demotest15_staging_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest15_stagingaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_staging.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest15_staging_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest15_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest15_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest15_dev" {
  provider = "aws.authlanding"
  name = "demotest15_dev_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest15_dev account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_dev.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest15_dev_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_admin_iam_role_list)}"
  user = "${local.demotest15_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest15_dev.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest15_dev" {
  provider = "aws.authlanding"
  name = "demotest15_dev_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest15_devaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_dev.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest15_dev_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest15_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest15_dev.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest15_dev" {
  provider = "aws.authlanding"
  name = "demotest15_dev_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest15_devaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest15_dev.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest15_dev_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest15_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest15_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest15_dev.arn}"
}
