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
