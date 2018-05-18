# creating manually, since there isn't a budget notification resource yet
# https://github.com/terraform-providers/terraform-provider-aws/issues/4548

locals {
  notification_cmd_prefix = <<EOF
aws budgets create-notification \
  --account-id ${aws_budgets_budget.budget.account_id} \
  --budget-name ${aws_budgets_budget.budget.name} \
  --subscribers SubscriptionType=SNS,Address=${aws_sns_topic.budget.arn} \
  --notification \
EOF
}

# when forecasted bill exceeds budget
resource "null_resource" "budget_forecast_notification" {
  triggers {
    budget_id = "${aws_budgets_budget.budget.id}"
    prefix    = "${local.notification_cmd_prefix}"
  }

  provisioner "local-exec" {
    command = "${local.notification_cmd_prefix} NotificationType=FORECASTED,ComparisonOperator=GREATER_THAN,Threshold=100,ThresholdType=PERCENTAGE"
  }
}

# when actual bill exceeds certain fractions of budget
resource "null_resource" "budget_percents_notifications" {
  count = "${length(var.warning_threshold_percents)}"

  triggers {
    budget_id = "${aws_budgets_budget.budget.id}"
    prefix    = "${local.notification_cmd_prefix}"
  }

  provisioner "local-exec" {
    command = "${local.notification_cmd_prefix} NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=${var.warning_threshold_percents[count.index]},ThresholdType=PERCENTAGE"
  }
}
