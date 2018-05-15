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

  # needed because, as of AWS provider v1.18.0, Terraform doesn't have a way to create the notification directly
  provisioner "local-exec" {
    # 80% usage
    command = <<EOF
aws budgets create-notification \
  --account-id ${data.aws_caller_identity.current.account_id} \
  --budget-name ${aws_budgets_budget.budget.name} \
  --notification NotificationType=ACTUAL,ComparisonOperator=GREATER_THAN,Threshold=80,ThresholdType=ABSOLUTE_VALUE \
  --subscribers SubscriptionType=SNS,Address=${var.budget_notification_topic_arn}
EOF
  }
}
