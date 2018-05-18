data "aws_ssm_parameter" "budget" {
  name = "${var.name}-budget"
}

locals {
  # workaround for trying to do conditionals with maps, since LinkedAccount can't be specified with an empty list
  # https://github.com/hashicorp/terraform/issues/12453#issuecomment-378033384
  cost_filters = {
    empty = {}

    not_empty = {
      LinkedAccount = "${join(",", var.account_ids)}"
    }
  }
}

resource "aws_budgets_budget" "budget" {
  name         = "${var.name}-monthly"
  budget_type  = "COST"
  limit_amount = "${data.aws_ssm_parameter.budget.value}"
  limit_unit   = "USD"

  # far in the future
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = "${local.cost_filters[length(var.account_ids) > 0 ? "not_empty" : "empty"]}"
}

# workaround for https://github.com/terraform-providers/terraform-provider-aws/issues/4548

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
