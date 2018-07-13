

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}



resource "aws_s3_bucket" "central_mon_account_bucket" {
    bucket = "${var.s3_bucket_name}"
    acl = "private"
    server_side_encryption_configuration {
    rule {
          apply_server_side_encryption_by_default {
              sse_algorithm     = "AES256"
          }
        }
}
}

resource "aws_guardduty_detector" "aws_guardduty_master" {
  enable = true
}

# Only to be used in multi account environment

/*resource "aws_guardduty_member" "aws_guardduty_member" {
  account_id         = "${var.aws_guardduty_member_account_number}"
  detector_id        = "${var.aws_guardduty_member_account_email}"
  email              = "required@example.com"
  invite             = true
  invitation_message = "Please accept guardduty invitation from Mater Account"
}*/


# To be integrate with FireEye Threat intellegense 
resource "aws_guardduty_threatintelset" "MyThreatIntelSet" {
  activate    = true
  detector_id = "${aws_guardduty_detector.aws_guardduty_master.id}"
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${aws_s3_bucket.central_mon_account_bucket.bucket}/${var.s3_bucket_name_key}"
  name        = "GuardDutyThreatIntelSet"
}
