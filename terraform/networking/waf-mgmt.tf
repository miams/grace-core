resource "aws_s3_bucket" "mgmt_access_log_bucket" {
  bucket   = "${var.mgmt_access_log_bucket}"
  acl      = "private"
  provider = "aws.mgmt"

  tags {
    Name        = "WAF ALB Access Logs"
    Environment = "Management"
  }
}

resource "aws_cloudformation_stack" "mgmt_waf" {
  name     = "waf-alb-stack"
  provider = "aws.mgmt"

  parameters {
    AccessLogBucket                        = "${aws_s3_bucket.dev_access_log_bucket.id}"
    SqlInjectionProtectionParam            = "yes"
    CrossSiteScriptingProtectionParam      = "yes"
    ActivateHttpFloodProtectionParam       = "yes"
    ActivateScansProbesProtectionParam     = "yes"
    ActivateReputationListsProtectionParam = "yes"
    ActivateBadBotProtectionParam          = "yes"
    SendAnonymousUsageData                 = "no"
    RequestThreshold                       = 400
    ErrorThreshold                         = 50
    WAFBlockPeriod                         = 240
  }

  disable_rollback = true

  capabilities = ["CAPABILITY_IAM"]

  template_body = "${file("aws-waf-security-automations-alb.template")}"
}
