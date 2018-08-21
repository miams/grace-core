data "aws_ssm_parameter" "spoketest_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "spoketest-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "spoketest_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "spoketest-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "spoketest_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "spoketest-tenant-viewonly-iam-role-list"
}

locals {
  spoketest_tenant_admin_iam_role_list     = ["${split(",", data.aws_ssm_parameter.spoketest_tenant_admin_iam_role_list.value)}"]
  spoketest_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.spoketest_tenant_poweruser_iam_role_list.value)}"]
  spoketest_tenant_viewonly_iam_role_list  = ["${split(",", data.aws_ssm_parameter.spoketest_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_spoketest_prod" {
  source = "../member_account"

  name                        = "tenant_spoketest_prod"
  email                       = "jasong.miller+spoketestprod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
}

module "tenant_spoketest_mgmt" {
  source = "../member_account"

  name                        = "tenant_spoketest_mgmt"
  email                       = "jasong.miller+spoketestmgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
}

# JGM - 06/21/18: Removing this because we're at AWS Organizations limit
# module "tenant_spoketest_staging" {
#   source = "../member_account"

#   name                        = "tenant_spoketest_staging"
#   email                       = "jasong.miller+spoketeststaging@gsa.gov"
#   authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
#   create_iam_roles            = "true"
#   grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

#   tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
#   tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
#   tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
# }

module "tenant_spoketest_dev" {
  source = "../member_account"

  name                        = "tenant_spoketest_dev"
  email                       = "jasong.miller+spoketestdev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
}

module "spoketest_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "spoketest"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+spoketestbudget@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_spoketest_prod.account_id}",
    "${module.tenant_spoketest_mgmt.account_id}",

    # "${module.tenant_spoketest_staging.account_id}",
    "${module.tenant_spoketest_dev.account_id}",
  ]
}

# Apply IAM roles to the users to allow them to assume the necessary roles. This should only be run if create-iam-roles == true
# Now we need to read the role list and interate through the named users and apply an inline sts-assume-role policy
# Admin roles first

resource "aws_iam_policy" "spoketest_sts_assume_admin_role_user_policy_mgmt" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_mgmt_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this tenant mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_mgmt.tenant_admin_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_admin_policy_mgmt" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_admin_iam_role_list)}"
  user       = "${local.spoketest_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_admin_role_user_policy_mgmt.arn}"
}

resource "aws_iam_policy" "spoketest_sts_assume_admin_role_user_policy_prod" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_prod_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this tenant prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_prod.tenant_admin_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_admin_policy_prod" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_admin_iam_role_list)}"
  user       = "${local.spoketest_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_admin_role_user_policy_prod.arn}"
}

resource "aws_iam_policy" "spoketest_sts_assume_admin_role_user_policy_dev" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_dev_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this tenant dev account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_dev.tenant_admin_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_admin_policy_dev" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_admin_iam_role_list)}"
  user       = "${local.spoketest_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_admin_role_user_policy_dev.arn}"
}

###
# PowerUser roles
###

resource "aws_iam_policy" "spoketest_sts_assume_poweruser_role_user_policy_mgmt" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_mgmt_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this tenant mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_mgmt.tenant_poweruser_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_poweruser_policy_mgmt" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_poweruser_iam_role_list)}"
  user       = "${local.spoketest_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_poweruser_role_user_policy_mgmt.arn}"
}

resource "aws_iam_policy" "spoketest_sts_assume_poweruser_role_user_policy_prod" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_prod_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this tenant prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_prod.tenant_poweruser_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_poweruser_policy_prod" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_poweruser_iam_role_list)}"
  user       = "${local.spoketest_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_poweruser_role_user_policy_prod.arn}"
}

resource "aws_iam_policy" "spoketest_sts_assume_poweruser_role_user_policy_dev" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_dev_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this tenant dev account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_dev.tenant_poweruser_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_poweruser_policy_dev" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_poweruser_iam_role_list)}"
  user       = "${local.spoketest_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_poweruser_role_user_policy_dev.arn}"
}

###
# ViewOnly Roles
###

resource "aws_iam_policy" "spoketest_sts_assume_viewonly_role_user_policy_mgmt" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_mgmt_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this tenant mgmt account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_mgmt.tenant_viewonly_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_viewonly_policy_mgmt" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_viewonly_iam_role_list)}"
  user       = "${local.spoketest_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_viewonly_role_user_policy_mgmt.arn}"
}

resource "aws_iam_policy" "spoketest_sts_assume_viewonly_role_user_policy_prod" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_prod_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this tenant prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_prod.tenant_viewonly_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_viewonly_policy_prod" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_viewonly_iam_role_list)}"
  user       = "${local.spoketest_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_viewonly_role_user_policy_prod.arn}"
}

resource "aws_iam_policy" "spoketest_sts_assume_viewonly_role_user_policy_dev" {
  provider    = "aws.authlanding"
  name        = "tenant_spoketest_dev_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this tenant dev account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${module.tenant_spoketest_dev.tenant_viewonly_role_arn}",
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "spoketest_attach_user_viewonly_policy_dev" {
  provider   = "aws.authlanding"
  count      = "${length(local.spoketest_tenant_viewonly_iam_role_list)}"
  user       = "${local.spoketest_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.spoketest_sts_assume_viewonly_role_user_policy_dev.arn}"
}
