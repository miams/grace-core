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
