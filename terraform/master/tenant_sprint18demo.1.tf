data "aws_ssm_parameter" "tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-sprint18-admin-iam-role-list"
}

data "aws_ssm_parameter" "tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-sprint18-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-sprint18-viewonly-iam-role-list"
}

locals {
  tenant_admin_iam_role_list     = ["${split(",", data.aws_ssm_parameter.tenant_admin_iam_role_list.value)}"]
  tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.tenant_poweruser_iam_role_list.value)}"]
  tenant_viewonly_iam_role_list  = ["${split(",", data.aws_ssm_parameter.tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_sprint18_prod" {
  source = "../member_account"

  name                        = "tenant-sprint18-prod"
  email                       = "jasong.miller+tenantsprint18prod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_sprint18_staging" {
  source = "../member_account"

  name                        = "tenant-sprint18-staging"
  email                       = "jasong.miller+tenantsprint18staging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_sprint18_dev" {
  source = "../member_account"

  name                        = "tenant-sprint18-dev"
  email                       = "jasong.miller+tenantsprint18dev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_sprint18_mgmt" {
  source = "../member_account"

  name                        = "tenant-sprint18-mgmt"
  email                       = "jasong.miller+tenantsprint18mgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"

  tenant_admin_iam_role_list     = ["${local.tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_viewonly_iam_role_list}"]
}

module "tenant_sprint18_budget" {
  source = "../budget"

  name = "tenantsprint18"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+tenantsprint18alerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_sprint18_prod.account_id}",
    "${module.tenant_sprint18_staging.account_id}",
    "${module.tenant_sprint18_dev.account_id}",
    "${module.tenant_sprint18_mgmt.account_id}",
  ]
}
