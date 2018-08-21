data "aws_ssm_parameter" "dependencytest_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "dependencytest-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "dependencytest_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "dependencytest-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "dependencytest_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "dependencytest-tenant-viewonly-iam-role-list"
}

locals {
  dependencytest_tenant_admin_iam_role_list     = ["${split(",", data.aws_ssm_parameter.dependencytest_tenant_admin_iam_role_list.value)}"]
  dependencytest_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.dependencytest_tenant_poweruser_iam_role_list.value)}"]
  dependencytest_tenant_viewonly_iam_role_list  = ["${split(",", data.aws_ssm_parameter.dependencytest_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_dependencytest_prod" {
  source = "../member_account"

  name                        = "tenant_dependencytest_prod"
  email                       = "jasong.miller+dependencytestprod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.dependencytest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.dependencytest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.dependencytest_tenant_viewonly_iam_role_list}"]
}

module "tenant_dependencytest_mgmt" {
  source = "../member_account"

  # depends_on = ["module.tenant_dependencytest_prod"]

  name                        = "tenant_dependencytest_mgmt"
  email                       = "jasong.miller+dependencytestmgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  tenant_admin_iam_role_list     = ["${local.dependencytest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.dependencytest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.dependencytest_tenant_viewonly_iam_role_list}"]
}

module "tenant_dependencytest_staging" {
  source = "../member_account"

  # depends_on = ["module.tenant_dependencytest_mgmt"]

  name                        = "tenant_dependencytest_staging"
  email                       = "jasong.miller+dependencyteststaging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  tenant_admin_iam_role_list     = ["${local.dependencytest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.dependencytest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.dependencytest_tenant_viewonly_iam_role_list}"]
}

module "tenant_dependencytest_dev" {
  source = "../member_account"

  # depends_on = ["module.tenant_dependencytest_staging"]

  name                        = "tenant_dependencytest_dev"
  email                       = "jasong.miller+dependencytestdev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  tenant_admin_iam_role_list     = ["${local.dependencytest_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.dependencytest_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.dependencytest_tenant_viewonly_iam_role_list}"]
}

module "dependencytest_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "dependencytest"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+budget@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_dependencytest_prod.account_id}",
    "${module.tenant_dependencytest_mgmt.account_id}",
    "${module.tenant_dependencytest_staging.account_id}",
    "${module.tenant_dependencytest_dev.account_id}",
  ]
}
