### master account ###

resource "aws_organizations_organization" "org" {}

### subaccounts ###

module "scp_test" {
  source = "./child_account"

  name  = "Aidan SCP test"
  email = "aidan.feldman+scp@gsa.gov"
}

module "broker_test" {
  source = "./child_account"

  name  = "Service Broker account"
  email = "aidan.feldman+broker@gsa.gov"
}
