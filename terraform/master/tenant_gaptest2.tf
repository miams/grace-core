module "tenant_gaptest2_prod" {
  source = "../member_account"

  name  = "tenant-gaptest2-prod"
  email = "jasong.miller+tenantgaptest2prod_test@gsa.gov"
}

module "tenant_gaptest2_staging" {
  source = "../member_account"

  name  = "tenant-gaptest2-staging"
  email = "jasong.miller+tenantgaptest2staging_test@gsa.gov"
}

module "tenant_gaptest2_dev" {
  source = "../member_account"

  name  = "tenant-gaptest2-dev"
  email = "jasong.miller+tenantgaptest2dev_test@gsa.gov"
}

module "tenant_gaptest2_mgmt" {
  source = "../member_account"

  name  = "tenant-gaptest2-mgmt"
  email = "jasong.miller+tenantgaptest2mgmt_test@gsa.gov"
}

module "tenant_gaptest2_budget" {
  source = "../budget"

  name = "tenantgaptest2"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "jasong.miller+tenantgaptest2alerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.tenant_gaptest2_prod.account_id}",
    "${module.tenant_gaptest2_staging.account_id}",
    "${module.tenant_gaptest2_dev.account_id}",
    "${module.tenant_gaptest2_mgmt.account_id}",
  ]
}
