# Grace monitoring account for GRACE platform - 07/19/18
# This account is intended for hosting AWS monitoring services such as GuardDuty, AWS config, Aws WAF Manager, Central logging etc. It will not have connectivity to on-prem.
# This account is similar to tenant account from build prospective but will be used by platfrom.
# We need decide if this account can be used for common services or not later, based ownership
# It only requires a prod account, no other environments.
# It will be added to the platform OU within the platform, which must be done manually.

# update: Build authlanding account
# update: Add description and provider for this account
#  update : Enable guardduty (Master) and create S3 for hostting common shared files like threatfile for guardduty




provider "aws" {
  alias = "gracemonitoring"

  assume_role {
    role_arn = "arn:aws:iam::${module.tenant_grace_monitoring_prod.account_id}:role/OrganizationAccountAccessRole"
  }
}


# Tenant file for grace_monitoring, autogenerated by python tool.
data "aws_ssm_parameter" "grace_monitoring_tenant_admin_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "grace_monitoring-tenant-admin-iam-role-list"
}

data "aws_ssm_parameter" "grace_monitoring_tenant_poweruser_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "grace_monitoring-tenant-poweruser-iam-role-list"
}

data "aws_ssm_parameter" "grace_monitoring_tenant_viewonly_iam_role_list" {
  provider = "aws.authlanding"

  # The name for this parameter must be unique to other tenants!
  name = "grace_monitoring-tenant-viewonly-iam-role-list"
}

data "aws_ssm_parameter" "grace_monitoring_guardduty_threatfeed_priv" {
  # Create parameter from console with name below in master account. Use kms key create secure string.
  name = "grace_monitoring_guardduty_threatfeed_priv"
}
data "aws_ssm_parameter" "grace_monitoring_guardduty_threatfeed_pub" {
  # Create parameter from console with name below in master account. Use kms key create secure string.
  name = "grace_monitoring_guardduty_threatfeed_pub"
}


locals {
  grace_monitoring_tenant_admin_iam_role_list = ["${split(",", data.aws_ssm_parameter.grace_monitoring_tenant_admin_iam_role_list.value)}"]
  grace_monitoring_tenant_poweruser_iam_role_list = ["${split(",", data.aws_ssm_parameter.grace_monitoring_tenant_poweruser_iam_role_list.value)}"]
  grace_monitoring_tenant_viewonly_iam_role_list = ["${split(",", data.aws_ssm_parameter.grace_monitoring_tenant_viewonly_iam_role_list.value)}"]
}

module "tenant_grace_monitoring_prod" {
  source = "github.com/gsa/grace-tf-module-member-account/terraform/modules/member_account"

  name = "tenant_grace_monitoring_prod"
  email = "manoj.chalise+devsecops@gsa.gov"
  authlanding_prod_account_id = "${module.authlanding_prod.account_id}"
  create_iam_roles = "true"
  grace_monitoring_prod_account_id = "${module.tenant_grace_monitoring_prod.account_id}"

  tenant_admin_iam_role_list = ["${local.grace_monitoring_tenant_admin_iam_role_list}"]
  tenant_poweruser_iam_role_list = ["${local.grace_monitoring_tenant_poweruser_iam_role_list}"]
  tenant_viewonly_iam_role_list = ["${local.grace_monitoring_tenant_viewonly_iam_role_list}"]
}

module "grace_monitoring_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "grace-monitoring"

  budget_notifications = [
    {
      protocol = "email"
      endpoint = "manoj.chalise@gsa.gov"
    }
  ]

  account_ids = [
    "${module.tenant_grace_monitoring_prod.account_id}",
  #  "${module.tenant_grace_monitoring_mgmt.account_id}",
  ]
}

# IAM role permission section - have to give sts-assume-role permission to users to allow them to switch to the roles.

resource "aws_iam_policy" "sts_assume_admin_role_user_policy_grace_monitoring_prod" {
  provider = "aws.authlanding"
  name = "grace_monitoring_prod_admin_assume_role_user_policy"
  description = "Allows this user to assume the admin role in this grace_monitoring_prod account"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_grace_monitoring_prod.tenant_admin_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_admin_role_user_policy_grace_monitoring_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.grace_monitoring_tenant_admin_iam_role_list)}"
  user = "${local.grace_monitoring_tenant_admin_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_admin_role_user_policy_grace_monitoring_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_poweruser_role_user_policy_grace_monitoring_prod" {
  provider = "aws.authlanding"
  name = "grace_monitoring_prod_poweruser_assume_role_user_policy"
  description = "Allows this user to assume the poweruser role in this grace_monitoring_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_grace_monitoring_prod.tenant_poweruser_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_poweruser_role_user_policy_grace_monitoring_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.grace_monitoring_tenant_poweruser_iam_role_list)}"
  user = "${local.grace_monitoring_tenant_poweruser_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_poweruser_role_user_policy_grace_monitoring_prod.arn}"
}

resource "aws_iam_policy" "sts_assume_viewonly_role_user_policy_grace_monitoring_prod" {
  provider = "aws.authlanding"
  name = "grace_monitoring_prod_viewonly_assume_role_user_policy"
  description = "Allows this user to assume the viewonly role in this grace_monitoring_prodaccount"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Resource": "${module.tenant_grace_monitoring_prod.tenant_viewonly_role_arn}",
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "sts_assume_viewonly_role_user_policy_grace_monitoring_prod_attachment" {
  provider = "aws.authlanding"
  count = "${length(local.grace_monitoring_tenant_viewonly_iam_role_list)}"
  user = "${local.grace_monitoring_tenant_viewonly_iam_role_list[count.index]}"
  policy_arn = "${aws_iam_policy.sts_assume_viewonly_role_user_policy_grace_monitoring_prod.arn}"
}


#-----S3 for hostting common shared files, such as threat file for guardduty----

resource "aws_s3_bucket" "central_mon_account_bucket" {
    provider    = "aws.gracemonitoring"
    bucket = "${var.s3_bucket_monitoring_account}"
    acl = "private"

    versioning {
    enabled = true
    }
    #logging {
    #  target_bucket = "${var.logging_bucket}"
    #  target_prefix = "s3/${local.bucket_id}/"
    #}
    server_side_encryption_configuration {
    rule {
          apply_server_side_encryption_by_default {
              sse_algorithm     = "AES256"
          }
        }
}
}

# Create a KMS key in master account to store secure string in parameter store. Use this key to store secure sting in master account
# SSM parameter are created manually from console.

resource "aws_kms_key" "grace_master_account_parameter_stores_kms_key" {
  description             = "KMS key to encrypt and decrypt parameter store objects in master account. Use this for storing GuardDuty secure string to download threat feeds"
  deletion_window_in_days = 30
  enable_key_rotation     = "true"
}

resource "aws_kms_alias" "grace_master_account_parameter_stores_kms_key_name" {
  name          = "alias/GuardDuty_Keys"
  target_key_id = "${aws_kms_key.grace_master_account_parameter_stores_kms_key.key_id}"
}

#----Enable GuardDuty and Configure threat feed source

resource "aws_guardduty_detector" "aws_guardduty_master" {
  provider    = "aws.gracemonitoring"
  enable = true
}

# Call a module to deploy threat feed lambda
module "grace_monitoring_guardduty_threatfeed" {

  source = "../platform/guardduty_lambda"
  deploy_guardduty_threatfeed_lambda = "true"
  threatfeed_output_bucket = "${aws_s3_bucket.central_mon_account_bucket.bucket}"
  threatfeed_priv_key = "${data.aws_ssm_parameter.grace_monitoring_guardduty_threatfeed_priv.value}"
  threatfeed_pub_key = "${data.aws_ssm_parameter.grace_monitoring_guardduty_threatfeed_pub.value}"
}
