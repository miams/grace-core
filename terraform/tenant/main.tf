data "aws_caller_identity" "current" {}

# created on the master account, even though it corresponds to the member accounts
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
}

# workaround for https://github.com/terraform-providers/terraform-provider-aws/issues/4548

locals {
  notification_cmd_prefix = <<EOF
aws budgets create-notification \
  --account-id ${data.aws_caller_identity.current.account_id} \
  --budget-name ${aws_budgets_budget.budget.name} \
  --subscribers SubscriptionType=SNS,Address=${aws_sns_topic.budget.arn} \
  --notification \
EOF
}

resource "null_resource" "budget_notifications" {
  triggers {
    budget_id = "${aws_budgets_budget.budget.id}"
    prefix    = "${local.notification_cmd_prefix}"
  }

  # when actual bill exceeds budget
  provisioner "local-exec" {
    command = "${local.notification_cmd_prefix} NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=${var.budget_limit},ThresholdType=ABSOLUTE_VALUE"
  }

  # when actual bill exceeds certain fraction of budget
  provisioner "local-exec" {
    command = "${local.notification_cmd_prefix} NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=${var.warning_threshold_pct},ThresholdType=PERCENTAGE"
  }

  # when forecasted bill exceeds budget
  provisioner "local-exec" {
    command = "${local.notification_cmd_prefix} NotificationType=FORECASTED,ComparisonOperator=GREATER_THAN,Threshold=${var.budget_limit},ThresholdType=ABSOLUTE_VALUE"
  }
}
