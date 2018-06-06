# AUTHLANDING Account for GRACE platform - 06/04/18
# This account is nothing but a place for IAM users to be managed. It will not have connectivity to on-prem.
# IAM roles in tenant accounts will inherit from this ID.
# It only requires a prod account, no other environments.
# It will be added to the platform OU within the platform, which must be done manually.

# DOCUPDATE: Build authlanding account
# DOCUPDATE: Add comma-delimited user list to authlanding account
# DOCUPDATE: SSM parameters must be encrypted - update README SSM command for budget to encrypted (SecureString)
# TODO: Add KMS keys for SSM parameter stores

module "authlanding_prod" {
  source = "../member_account"

  name                        = "authlanding-prod"
  email                       = "devsecops-core+authlanding@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles            = "false"
}

module "authlanding_budget" {
  source = "../budget"

  name = "authlanding"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "devsecops-core+authlandingalerts@gsa.gov"
    },
  ]

  account_ids = [
    "${module.authlanding_prod.account_id}",
  ]
}

provider "aws" {
  alias = "authlanding"

  assume_role {
    role_arn = "arn:aws:iam::${module.authlanding_prod.account_id}:role/OrganizationAccountAccessRole"
  }
}

### USER MANAGEMENT
# This SSM Parameter Store will contain a comma-delimited list of users that will be created with the resource below.
data "aws_ssm_parameter" "authlanding_user_list" {
  provider = "aws.authlanding"
  name     = "authlanding-user-list"
}

locals {
  user_list = ["${split(",", data.aws_ssm_parameter.authlanding_user_list.value)}"]
}

resource "aws_iam_user" "iam_users" {
  count    = "${length(local.user_list)}"
  provider = "aws.authlanding"
  name     = "${local.user_list[count.index]}"
}

### END USER MANAGEMENT

