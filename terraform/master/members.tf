module "scp_test" {
  source = "../member_account"

  name                        = "Aidan SCP test"
  email                       = "aidan.feldman+scp@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "false"
}

module "broker_test" {
  source = "../member_account"

  name                        = "Service Broker account"
  email                       = "aidan.feldman+broker@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "false"
}

module "devsecops_test_3" {
  source = "../member_account"

  name                        = "gsa-devsecops-test3"
  email                       = "gsa-devsecops-test3@saic.com"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "false"
}
