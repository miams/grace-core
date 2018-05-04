module "scp_test" {
  source = "../member_account"

  name  = "Aidan SCP test"
  email = "aidan.feldman+scp@gsa.gov"
}

module "broker_test" {
  source = "../member_account"

  name  = "Service Broker account"
  email = "aidan.feldman+broker@gsa.gov"
}

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
