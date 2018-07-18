# Configuration to enable guardduty when member account is created based on Boolean "enable_memeber_guardduty"
# This also adds client (member) aws account as member in master guardduty hosted at platfrom grace monitoring account.
# This code will enforce enabling guardduty and integration to master guardduty on all member account when account is created once Boolean is set to true.
# When account is added to master guardduty , invitation will be sent to memeber account and invitation will showup in tenant guardduty console. They have to manually account invitation for one time.



resource "aws_guardduty_detector" "aws_guardduty_member" {
  count      = "${var.enable_member_guardduty == "true" ? 1 : 0}"

  provider = "aws.child"
  enable = true
}

resource "aws_guardduty_member" "aws_guardduty_member" {
  count      = "${var.enable_member_guardduty == "true" ? 1 : 0}"

  provider    = "aws.gracemonitoring"
  account_id         = "${aws_organizations_account.child.id}"
  detector_id        = "${var.guardduty_master_detector_id}"
  email              = "${var.email}"
  invite             = true
  invitation_message = "Please accept guardduty invitation from GRACE Monitoring Account"
}
