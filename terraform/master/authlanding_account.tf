# AUTHLANDING Account for GRACE platform - 06/04/18
# This account is nothing but a place for IAM users to be managed. It will not have connectivity to on-prem.
# IAM roles in tenant accounts will inherit from this ID.
# It only requires a prod account, no other environments.
# It will be added to the platform OU within the platform, which must be done manually.

module "authlanding_prod" {
  source = "../member_account"

  name  = "authlanding-prod"
  email = "devsecops-core+authlanding@gsa.gov"
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
