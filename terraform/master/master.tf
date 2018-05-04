terraform {
  backend "s3" {
    region = "us-east-1"
  }
}

resource "aws_organizations_organization" "org" {}
