variable "iam_role_name" {
  default = "OrganizationAccountAccessRole"
}

### master account ###

resource "aws_organizations_organization" "org" {}

resource "aws_organizations_account" "scp_test" {
  name  = "Aidan SCP test"
  email = "aidan.feldman+scp@gsa.gov"
}

### subaccounts ###

provider "aws" {
  alias = "scp_test"

  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.scp_test.id}:role/${var.iam_role_name}"
  }
}

# just an arbitrary resource to create in the subaccount
resource "aws_eip" "ip" {
  provider = "aws.scp_test"
}
