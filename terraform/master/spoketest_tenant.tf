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

  tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
}

module "tenant_spoketest_staging" {
  source = "../member_account"

  name                        = "tenant_spoketest_staging"
  email                       = "jasong.miller+spoketeststaging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
}

module "tenant_spoketest_dev" {
  source = "../member_account"

  name                        = "tenant_spoketest_dev"
  email                       = "jasong.miller+spoketestdev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.spoketest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.spoketest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.spoketest_tenant_viewonly_iam_role_list}"]
}

module "spoketest_budget" {
  source = "../budget"

  name = "spoketest"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+spoketestbudget@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_spoketest_spoketest_prod.account_id}",
    "${module.tenant_spoketest_spoketest_mgmt.account_id}",
    "${module.tenant_spoketest_spoketest_staging.account_id}",
    "${module.tenant_spoketest_spoketest_dev.account_id}",
  ]
}
