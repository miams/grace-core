module "tenant_gaptest_prod" {
  source = "../member_account"

  name  = "tenant-1-prod"
  email = "jasong.miller+tenantgaptestprod@gsa.gov"
}

module "tenant_gaptest_staging" {
  source = "../member_account"

  name  = "tenant-1-staging"
  email = "jasong.miller+tenantgapteststaging@gsa.gov"
}

module "tenant_gaptest_dev" {
  source = "../member_account"

  name  = "tenant-1-dev"
  email = "jasong.miller+tenantgaptestdev@gsa.gov"
}

module "tenant_gaptest_mgmt" {
  source = "../member_account"

  name  = "tenant-1-mgmt"
  email = "jasong.miller+tenantgaptestmgmt@gsa.gov"
}

module "tenant_gaptest_budget" {
  source = "../budget"

  name = "gaptest"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+tenantgaptestalerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_gaptest_prod.account_id}",
    "${module.tenant_gaptest_staging.account_id}",
    "${module.tenant_gaptest_dev.account_id}",
    "${module.tenant_gaptest_mgmt.account_id}",
  ]
}
