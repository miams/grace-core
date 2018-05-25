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

module "devsecops_test_3" {
  source = "../member_account"

  name  = "gsa-devsecops-test3"
  email = "gsa-devsecops-test3@saic.com"
}
