data "aws_ssm_parameter" "tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-1-admin-iam-role-list"
}

data "aws_ssm_parameter" "tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-1-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-1-viewonly-iam-role-list"
}

locals {
  tenant_admin_iam_role_list     = ["${split(",", data.aws_ssm_parameter.tenant_admin_iam_role_list.value)}"]
  tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.tenant_poweruser_iam_role_list.value)}"]
  tenant_viewonly_iam_role_list  = ["${split(",", data.aws_ssm_parameter.tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_1_prod" {
  source = "../member_account"

  name                        = "tenant-1-prod"
  email                       = "jasong.miller+tenant1prod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_1_staging" {
  source = "../member_account"

  name                        = "tenant-1-staging"
  email                       = "jasong.miller+tenant1staging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_1_dev" {
  source = "../member_account"

  name                        = "tenant-1-dev"
  email                       = "jasong.miller+tenant1dev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_1_mgmt" {
  source = "../member_account"

  name                        = "tenant-1-mgmt"
  email                       = "jasong.miller+tenant1mgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_1_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "tenant1"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+tenant1alerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_1_prod.account_id}",
    "${module.tenant_1_staging.account_id}",
    "${module.tenant_1_dev.account_id}",
    "${module.tenant_1_mgmt.account_id}",
  ]
}
