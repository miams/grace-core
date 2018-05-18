module "tenant_1_prod" {
  source = "../member_account"

  name  = "tenant-1-prod"
  email = "jasong.miller+tenant1prod@gsa.gov"
}

module "tenant_1_staging" {
  source = "../member_account"

  name  = "tenant-1-staging"
  email = "jasong.miller+tenant1staging@gsa.gov"
}

module "tenant_1_dev" {
  source = "../member_account"

  name  = "tenant-1-dev"
  email = "jasong.miller+tenant1dev@gsa.gov"
}

module "tenant_1_mgmt" {
  source = "../member_account"

  name  = "tenant-1-mgmt"
  email = "jasong.miller+tenant1mgmt@gsa.gov"
}

data "aws_ssm_parameter" "tenant_1_budget" {
  name = "tenant1-budget"
}

module "tenant_1_budget" {
  source = "../budget"

  name         = "tenant1"
  budget_limit = "${data.aws_ssm_parameter.tenant_1_budget.value}"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "aidan.feldman+tenant1alerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_1_prod.account_id}",
    "${module.tenant_1_staging.account_id}",
    "${module.tenant_1_dev.account_id}",
    "${module.tenant_1_mgmt.account_id}",
  ]
}
