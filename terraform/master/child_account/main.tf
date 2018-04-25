resource "aws_organizations_account" "child" {
  # provider = <master, inherited from top level>

  name  = "${var.name}"
  email = "${var.email}"
}

provider "aws" {
  alias = "child"

  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.child.id}:role/${var.iam_role_name}"
  }
}

# just an arbitrary resource to create in the subaccount
resource "aws_eip" "ip" {
  provider = "aws.child"
}
