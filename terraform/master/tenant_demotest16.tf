# Tenant file for demotest16, autogenerated by python tool.
data "aws_ssm_parameter" "demotest16_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest16-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "demotest16_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest16-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "demotest16_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest16-tenant-viewonly-iam-role-list"
}

locals {
  demotest16_tenant_admin_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest16_tenant_admin_iam_role_list.value)}"]
  demotest16_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest16_tenant_poweruser_iam_role_list.value)}"]
  demotest16_tenant_viewonly_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest16_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_demotest16_prod" {
  source = "../member_account"

  name = "tenant_demotest16_prod"
  email = "jasong.miller+demotest16prod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest16_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest16_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest16_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest16_mgmt" {
  source = "../member_account"

  name = "tenant_demotest16_mgmt"
  email = "jasong.miller+demotest16mgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest16_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest16_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest16_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest16_staging" {
  source = "../member_account"

  name = "tenant_demotest16_staging"
  email = "jasong.miller+demotest16staging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest16_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest16_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest16_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest16_dev" {
  source = "../member_account"

  name = "tenant_demotest16_dev"
  email = "jasong.miller+demotest16dev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.demotest16_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest16_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.demotest16_tenant_viewonly_iam_role_list}"]
}

module "demotest16_budget" {
  source = "../budget"

  name = "demotest16"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+demotest16budget@gsa.gov"
    }
  ]

  account_ids = [
    "${module.tenant_demotest16_prod.account_id}",
    "${module.tenant_demotest16_mgmt.account_id}",
    "${module.tenant_demotest16_staging.account_id}",
    "${module.tenant_demotest16_dev.account_id}",
  ]
}

# IAM role permission section - have to give sts-assume-role permission to users to allow them to switch to the roles.

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest16_prod" {
  provider = "aws.authlanding"
  name = "demotest16_prod_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest16_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_prod.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest16_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_admin_iam_role_list)}"
  user = "${local.demotest16_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest16_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest16_prod" {
  provider = "aws.authlanding"
  name = "demotest16_prod_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest16_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_prod.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest16_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest16_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest16_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest16_prod" {
  provider = "aws.authlanding"
  name = "demotest16_prod_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest16_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_prod.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest16_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest16_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest16_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest16_mgmt" {
  provider = "aws.authlanding"
  name = "demotest16_mgmt_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest16_mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_mgmt.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest16_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_admin_iam_role_list)}"
  user = "${local.demotest16_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest16_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest16_mgmt" {
  provider = "aws.authlanding"
  name = "demotest16_mgmt_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest16_mgmtaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_mgmt.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest16_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest16_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest16_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest16_mgmt" {
  provider = "aws.authlanding"
  name = "demotest16_mgmt_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest16_mgmtaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_mgmt.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest16_mgmt_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest16_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest16_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest16_staging" {
  provider = "aws.authlanding"
  name = "demotest16_staging_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest16_staging account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_staging.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest16_staging_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_admin_iam_role_list)}"
  user = "${local.demotest16_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest16_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest16_staging" {
  provider = "aws.authlanding"
  name = "demotest16_staging_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest16_stagingaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_staging.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest16_staging_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest16_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest16_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest16_staging" {
  provider = "aws.authlanding"
  name = "demotest16_staging_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest16_stagingaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_staging.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest16_staging_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest16_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest16_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest16_dev" {
  provider = "aws.authlanding"
  name = "demotest16_dev_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest16_dev account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_dev.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest16_dev_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_admin_iam_role_list)}"
  user = "${local.demotest16_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest16_dev.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest16_dev" {
  provider = "aws.authlanding"
  name = "demotest16_dev_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest16_devaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_dev.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest16_dev_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_poweruser_iam_role_list)}"
  user = "${local.demotest16_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest16_dev.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest16_dev" {
  provider = "aws.authlanding"
  name = "demotest16_dev_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest16_devaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest16_dev.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest16_dev_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.demotest16_tenant_viewonly_iam_role_list)}"
  user = "${local.demotest16_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest16_dev.arn}"
}

