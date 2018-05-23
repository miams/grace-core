provider "aws" {
  region = "${var.default_region}"
}

provider "aws" {
  alias  = "prod"
  region = "${var.prod_region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/${var.iam_role_name}"
  }
}

provider "aws" {
  alias  = "mgmt"
  region = "${var.mgmt_region}"

  # assume_role {
  #   role_arn = "arn:aws:iam::${var.mgmt_account_id}:role/${var.iam_role_name}"
  # }
}

data "aws_caller_identity" "default" {
  provider = "aws"
}

data "aws_caller_identity" "prod" {
  provider = "aws.prod"
}

data "aws_caller_identity" "mgmt" {
  provider = "aws.mgmt"
}
