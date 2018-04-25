### master account ###

resource "aws_organizations_organization" "org" {}

### subaccounts ###

module "scp_test" {
  source = "./child_account"

  name  = "Aidan SCP test"
  email = "aidan.feldman+scp@gsa.gov"
}
