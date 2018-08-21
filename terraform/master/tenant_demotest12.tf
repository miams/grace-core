# Tenant file for demotest12, autogenerated by python tool.
data "aws_ssm_parameter" "demotest12_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest12-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "demotest12_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest12-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "demotest12_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "demotest12-tenant-viewonly-iam-role-list"
}

locals {
  demotest12_tenant_admin_iam_role_list     = ["${split(",", data.aws_ssm_parameter.demotest12_tenant_admin_iam_role_list.value)}"]
  demotest12_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.demotest12_tenant_poweruser_iam_role_list.value)}"]
  demotest12_tenant_viewonly_iam_role_list  = ["${split(",", data.aws_ssm_parameter.demotest12_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_demotest12_prod" {
  source = "../member_account"

  name                        = "tenant_demotest12_prod"
  email                       = "jasong.miller+demotest12prod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.demotest12_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest12_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.demotest12_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest12_mgmt" {
  source = "../member_account"

  name                        = "tenant_demotest12_mgmt"
  email                       = "jasong.miller+demotest12mgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.demotest12_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest12_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.demotest12_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest12_staging" {
  source = "../member_account"

  name                        = "tenant_demotest12_staging"
  email                       = "jasong.miller+demotest12staging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.demotest12_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest12_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.demotest12_tenant_viewonly_iam_role_list}"]
}

module "tenant_demotest12_dev" {
  source = "../member_account"

  name                        = "tenant_demotest12_dev"
  email                       = "jasong.miller+demotest12dev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"
  
  tenant_admin_iam_role_list     = ["${local.demotest12_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.demotest12_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.demotest12_tenant_viewonly_iam_role_list}"]
}

module "demotest12_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "demotest12"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+budget@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_demotest12_prod.account_id}",
    "${module.tenant_demotest12_mgmt.account_id}",
    "${module.tenant_demotest12_staging.account_id}",
    "${module.tenant_demotest12_dev.account_id}",
  ]
}

# IAM role permission section - have to give sts-assume-role permission to users to allow them to switch to the roles.

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest12_prod" {
  provider    = "aws.authlanding"
  name        = "demotest12_prod_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest12_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_prod.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest12_prod_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_admin_iam_role_list)}"
  user       = "${local.demotest12_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest12_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest12_prod" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_prod_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest12_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_prod.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest12_prod_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_poweruser_iam_role_list)}"
  user       = "${local.demotest12_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest12_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest12_prod" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_prod_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest12_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_prod.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest12_prod_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_viewonly_iam_role_list)}"
  user       = "${local.demotest12_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest12_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest12_mgmt" {
  provider    = "aws.authlanding"
  name        = "demotest12_mgmt_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest12_mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_mgmt.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest12_mgmt_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_admin_iam_role_list)}"
  user       = "${local.demotest12_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest12_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest12_mgmt" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_mgmt_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest12_mgmtaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_mgmt.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest12_mgmt_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_poweruser_iam_role_list)}"
  user       = "${local.demotest12_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest12_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest12_mgmt" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_mgmt_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest12_mgmtaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_mgmt.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest12_mgmt_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_viewonly_iam_role_list)}"
  user       = "${local.demotest12_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest12_mgmt.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest12_staging" {
  provider    = "aws.authlanding"
  name        = "demotest12_staging_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest12_staging account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_staging.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest12_staging_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_admin_iam_role_list)}"
  user       = "${local.demotest12_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest12_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest12_staging" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_staging_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest12_stagingaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_staging.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest12_staging_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_poweruser_iam_role_list)}"
  user       = "${local.demotest12_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest12_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest12_staging" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_staging_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest12_stagingaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_staging.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest12_staging_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_viewonly_iam_role_list)}"
  user       = "${local.demotest12_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest12_staging.arn}"
}

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_demotest12_dev" {
  provider    = "aws.authlanding"
  name        = "demotest12_dev_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this demotest12_dev account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_dev.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_demotest12_dev_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_admin_iam_role_list)}"
  user       = "${local.demotest12_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_demotest12_dev.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_demotest12_dev" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_dev_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this demotest12_devaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_dev.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_demotest12_dev_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_poweruser_iam_role_list)}"
  user       = "${local.demotest12_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_demotest12_dev.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_demotest12_dev" {
  provider    = "aws.authlanding"
  name        = "demotest12_demotest12_dev_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this demotest12_devaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_demotest12_dev.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_demotest12_dev_attachment" {
  provider   = "aws.authlanding"
  count      = "${length(local.demotest12_tenant_viewonly_iam_role_list)}"
  user       = "${local.demotest12_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_demotest12_dev.arn}"
}

resource "aws_organizations_policy_attachment" "tenant_demotest12_prod" {
  policy_id = "${aws_organizations_policy.ise_approved.id}"
  target_id = "${module.tenant_demotest12_prod.account_id}"
}

resource "aws_organizations_policy_attachment" "tenant_demotest12_mgmt" {
  policy_id = "${aws_organizations_policy.ise_approved.id}"
  target_id = "${module.tenant_demotest12_mgmt.account_id}"
}

resource "aws_organizations_policy_attachment" "tenant_demotest12_staging" {
  policy_id = "${aws_organizations_policy.ise_approved.id}"
  target_id = "${module.tenant_demotest12_staging.account_id}"
}

resource "aws_organizations_policy_attachment" "tenant_demotest12_dev" {
  policy_id = "${aws_organizations_policy.ise_approved.id}"
  target_id = "${module.tenant_demotest12_dev.account_id}"
}
