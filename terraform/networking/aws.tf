provider "aws" {
  region = "${var.default_region}"
}

provider "aws" {
  alias = "prod"
  region = "${var.prod_region}"
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/${var.iam_role_name}"
  }
}

provider "aws" {
  alias = "dev"
  region = "${var.dev_region}"
  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/${var.iam_role_name}"
  }
}

provider "aws" {
  alias = "staging"
  region = "${var.staging_region}"
  assume_role {
    role_arn = "arn:aws:iam::${var.staging_account_id}:role/${var.iam_role_name}"
  }
}

provider "aws" {
  alias = "mgmt"
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

data "aws_caller_identity" "dev" {
  provider = "aws.dev"
}

data "aws_caller_identity" "staging" {
  provider = "aws.staging"
}

data "aws_caller_identity" "mgmt" {
  provider = "aws.mgmt"
}