resource "aws_organizations_organization" "org" {}

data "aws_s3_bucket_object" "scp" {
  bucket = "${var.bucket}"
  key    = "service_control_policy.json"
}

resource "aws_organizations_policy" "ise_approved" {
  name    = "ise_approved"
  content = "${data.aws_s3_bucket_object.scp.body}"
}

resource "aws_organizations_policy_attachment" "tenants" {
  policy_id = "${aws_organizations_policy.ise_approved.id}"

  # Organizational Unit: Tenants
  # hard-coded while waiting for https://github.com/terraform-providers/terraform-provider-aws/pull/4207
  target_id = "ou-bgtv-tu73r6dm"
}

module "master_budget" {
  source = "github.com/gsa/grace-tf-module-budget/terraform/modules/budget"

  name = "master"
}

# This tenant also has a lambda function that will query the tenant accounts in a sub OU to get the AWS accounts IDs.
# 08/08/18 by Jason Miller - jasong.miller@gsa.gov

resource "aws_s3_bucket" "tenant_info_bucket" {
  bucket = "grace-tenant-info"
  acl    = "private"
  policy = "${data.template_file.tenant_info_bucket_policy.rendered}"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags {
    Purpose = "Stores information about the tenant subaccount IDs for other grace-core elements to use."
  }
}

data "template_file" "tenant_info_bucket_policy" {
    template = "${file("${path.module}/files/tenant-info-bucket-policy.json")}"
    vars = {
      sharedservices_prod_account_id = "${module.tenant_gracesharedservices_prod.account_id}"
      sharedservices_mgmt_account_id = "${module.tenant_gracesharedservices_mgmt.account_id}"
    }
}

resource "aws_iam_role" "tenant_account_lister_role" {
  name = "tenant-account-lister-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# TODO: Tighten up this policy
resource "aws_iam_role_policy" "tenant_account_lister_role_policy" {
  name = "tenant_account_lister_role_policy"
  role = "${aws_iam_role.tenant_account_lister_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "lambda_tenant_account_lister_file" {
  type        = "zip"
  source_file = "${path.module}/files/tenant-account-lister.py"
  output_path = "${path.module}/files/tenant-account-lister.py.zip"
}

resource "aws_lambda_function" "lambda_tenant_account_lister_function" {
  filename      = "${path.module}/files/tenant-account-lister.py.zip"
  function_name = "tenant-account-lister"
  role          = "${aws_iam_role.tenant_account_lister_role.arn}"
  handler       = "tenant-account-lister.lambda_handler"
  runtime       = "python3.6"
}

resource "aws_cloudwatch_event_rule" "tenant_account_lister_event" {
  name                = "tenant-account-lister-run-hourly"
  description         = "Runs tenant account lister at the top of every hour"
  schedule_expression = "cron(1 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_backup_function_event" {
  rule      = "${aws_cloudwatch_event_rule.tenant_account_lister_event.name}"
  target_id = "lambda_tenant_account_lister_function"
  arn       = "${aws_lambda_function.lambda_tenant_account_lister_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_tenant_account_lister_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_tenant_account_lister_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.tenant_account_lister_event.arn}"
}

# End tenant_account_lister lambda function resources