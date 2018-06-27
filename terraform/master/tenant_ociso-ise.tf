data "aws_ssm_parameter" "ociso-ise_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "ociso-ise-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "ociso-ise_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "ociso-ise-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "ociso-ise_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "ociso-ise-tenant-viewonly-iam-role-list"
}

locals {
  ociso-ise_tenant_admin_iam_role_list = ["${split(",", data.aws_ssm_parameter.ociso-ise_tenant_admin_iam_role_list.value)}"]
  ociso-ise_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.ociso-ise_tenant_poweruser_iam_role_list.value)}"]
  ociso-ise_tenant_viewonly_iam_role_list = ["${split(",", data.aws_ssm_parameter.ociso-ise_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_ociso-ise_prod" {
  source = "../member_account"

  name = "tenant_ociso-ise_prod"
  email = "manoj.chalise+ociso-ise@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.ociso-ise_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.ociso-ise_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.ociso-ise_tenant_viewonly_iam_role_list}"]
}
/*
module "tenant_ociso-ise_mgmt" {
  source = "../member_account"

  name = "tenant_ociso-ise_mgmt"
  email = "manoj.chalise+ociso-ise@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"

  tenant_admin_iam_role_list = ["${local.ociso-ise_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.ociso-ise_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.ociso-ise_tenant_viewonly_iam_role_list}"]
}*/

module "ociso-ise_budget" {
  source = "../budget"

  name = "ociso-ise"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "manoj.chalise@gsa.gov"
    }
  ]

  account_ids = [
    "${module.tenant_ociso-ise_prod.account_id}",
  #  "${module.tenant_ociso-ise_mgmt.account_id}",
  ]}
