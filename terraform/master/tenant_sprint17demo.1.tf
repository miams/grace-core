data "aws_ssm_parameter" "tenant_sprint17_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-sprint17-admin-iam-role-list"
}

data "aws_ssm_parameter" "tenant_sprint17_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-sprint17-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "tenant_sprint17_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "tenant-sprint17-viewonly-iam-role-list"
}

locals {
  tenant_sprint17_admin_iam_role_list     = ["${split(",", data.aws_ssm_parameter.tenant_sprint17_admin_iam_role_list.value)}"]
  tenant_sprint17_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.tenant_sprint17_poweruser_iam_role_list.value)}"]
  tenant_sprint17_viewonly_iam_role_list  = ["${split(",", data.aws_ssm_parameter.tenant_sprint17_viewonly_iam_role_list.value)}"]
}

module "tenant_sprint17_prod" {
  source = "../member_account"

  name                        = "tenant-sprint17-prod"
  email                       = "jasong.miller+tenantsprint17prod@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.tenant_sprint17_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_sprint17_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_sprint17_viewonly_iam_role_list}"]
}

module "tenant_sprint17_staging" {
  source = "../member_account"

  name                        = "tenant-sprint17-staging"
  email                       = "jasong.miller+tenantsprint17staging@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.tenant_sprint17_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_sprint17_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_sprint17_viewonly_iam_role_list}"]
}

module "tenant_sprint17_dev" {
  source = "../member_account"

  name                        = "tenant-sprint17-dev"
  email                       = "jasong.miller+tenantsprint17dev@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list     = ["${local.tenant_sprint17_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_sprint17_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_sprint17_viewonly_iam_role_list}"]
}

module "tenant_sprint17_mgmt" {
  source = "../member_account"

  name                        = "tenant-sprint17-mgmt"
  email                       = "jasong.miller+tenantsprint17mgmt@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"
  
  tenant_admin_iam_role_list     = ["${local.tenant_sprint17_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.tenant_sprint17_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list  = ["${local.tenant_sprint17_viewonly_iam_role_list}"]
}

module "tenant_sprint17_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "tenantsprint17"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+tenantsprint17alerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_sprint17_prod.account_id}",
    "${module.tenant_sprint17_staging.account_id}",
    "${module.tenant_sprint17_dev.account_id}",
    "${module.tenant_sprint17_mgmt.account_id}",
  ]
}
