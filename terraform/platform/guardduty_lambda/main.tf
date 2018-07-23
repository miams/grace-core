# Module deploys role, IAM policy , schedule event rule for lambda that download threat feed and updates guardduty, when download is complete.
# Lambda downloads threat feed and updated guardduty threat feed list.
# See variable file for list of valiables to be passed for this module.
# This needs to be deployed on only on master (platform) GuardDuty, all member (tenant) guardduty gets replica from master.


resource "aws_iam_role" "guarddutyFeed_lambda_role" {
  count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
  provider    = "aws.gracemonitoring"

  name = "GuarddutyFeed_Lambda_Role"

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


resource "aws_iam_policy" "guardDutyfeed_lambda_policy" {
  count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
  provider    = "aws.gracemonitoring"

  name        = "GuardDutyFeed_Lambda_Policy"
  path        = "/"
  description = "GuardDutyFeed_Lambda_Policy"
  policy      = "${file("../platform/guardduty_lambda/files/GuardDutyFeed_Lambda_Policy.json")}"
}


resource "aws_iam_role_policy_attachment" "guardDutyfeed_lambda_policy_attachment" {
  count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
  provider    = "aws.gracemonitoring"

  role       = "${aws_iam_role.guarddutyFeed_lambda_role.name}"
  policy_arn = "${aws_iam_policy.guardDutyfeed_lambda_policy.arn}"
}


resource "aws_cloudwatch_event_rule" "guarddutyFeed_lambda_schedule" {
    count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
    provider    = "aws.gracemonitoring"

    name = "GuardDutyFeed_Lambda_Schedule"
    description = "Fires every One Day"
    schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "guarddutyFeed_lambda_schedule_event" {
    count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
    provider    = "aws.gracemonitoring"

    rule = "${aws_cloudwatch_event_rule.guarddutyFeed_lambda_schedule.name}"
    target_id = "check_foo"
    arn = "${aws_lambda_function.GuardDuty_Feed.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_GuardDuty_Feed" {
    count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
    provider    = "aws.gracemonitoring"

    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.GuardDuty_Feed.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.guarddutyFeed_lambda_schedule.arn}"
}

resource "aws_kms_key" "GuardDuty_Feed_kms_key" {
  count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
  provider    = "aws.gracemonitoring"

  description             = "Kms Key to encrypt GuardDuty_Feed Lambda and ThreatFeed Priv/Pub key"
  deletion_window_in_days = 30
  enable_key_rotation     = "true"
}

resource "aws_lambda_function" "GuardDuty_Feed" {
    count = "${var.deploy_guardduty_threatfeed_lambda == "true" ? 1 : 0}"
    provider    = "aws.gracemonitoring"

    filename = "../platform/guardduty_lambda/files/GuardDutyFeed.zip"
    function_name = "GuardDutyFeed"
    role = "${aws_iam_role.guarddutyFeed_lambda_role.arn}"
    handler = "lambda_function.lambda_handler"
    runtime          = "python2.7"
    source_code_hash = "${base64sha256(file("../platform/guardduty_lambda/files/GuardDutyFeed.zip"))}"
    kms_key_arn = "${aws_kms_key.GuardDuty_Feed_kms_key.arn}"
    timeout = 45

     environment {
       variables = {
            DAYS_REQUESTED = "7"
            LOG_LEVEL = "INFO"
            OUTPUT_BUCKET = "${var.threatfeed_output_bucket}"
            PRIVATE_KEY = "${var.threatfeed_priv_key}"
            PUBLIC_KEY = "${var.threatfeed_pub_key}"
        }
    }
}
