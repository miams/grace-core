resource "aws_sns_topic" "budget" {
  name = "budget-notifications"
}

resource "aws_sns_topic_policy" "budget" {
  arn    = "${aws_sns_topic.budget.arn}"
  policy = "${file("${path.module}/files/sns_policy.json")}"
}

# go through a CloudFormation stack because Terraform doesn't support email subscriptions
# https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email
resource "aws_cloudformation_stack" "budget_notification_subscription" {
  name          = "budget-notifications"
  template_body = "${file("${path.module}/files/sns_template.json")}"

  parameters {
    SNSTopic             = "${aws_sns_topic.budget.arn}"
    SubscriptionEndPoint = "aidan.feldman+tenant1alerts@gsa.gov"
  }
}
