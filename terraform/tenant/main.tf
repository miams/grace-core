data "aws_caller_identity" "current" {}

# created on the master account, even though it corresponds to the member accounts

resource "aws_sns_topic" "budget" {
  name = "${var.name}-budget"
}

resource "aws_sns_topic_policy" "default" {
  arn    = "${aws_sns_topic.budget.arn}"
  policy = "${file("${path.module}/files/sns_policy.json")}"
}

# go through a CloudFormation stack because Terraform doesn't support email subscriptions
# https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email
resource "aws_cloudformation_stack" "sns_subscription" {
  name          = "${var.name}-budget"
  template_body = "${file("${path.module}/files/sns_template.json")}"

  parameters {
    SNSTopic             = "${aws_sns_topic.budget.arn}"
    SubscriptionEndPoint = "${var.budget_notification_email}"
  }
}

resource "aws_budgets_budget" "budget" {
  name         = "budget-${var.name}-monthly"
  budget_type  = "COST"
  limit_amount = "${var.budget_limit}"
  limit_unit   = "USD"

  # far in the future
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters {
    LinkedAccount = "${join(",", var.account_ids)}"
  }

  # needed because, as of AWS provider v1.18.0, Terraform doesn't have a way to create the notification directly
  provisioner "local-exec" {
    # 80% usage
    command = <<EOF
aws budgets create-notification \
  --account-id ${data.aws_caller_identity.current.account_id} \
  --budget-name ${aws_budgets_budget.budget.name} \
  --notification NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=80,ThresholdType=ABSOLUTE_VALUE \
  --subscribers SubscriptionType=SNS,Address=${aws_sns_topic.budget.arn}
EOF
  }
}
