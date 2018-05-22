resource "aws_s3_bucket" "dev_access_log_bucket" {
  bucket   = "${var.dev_access_log_bucket}"
  acl      = "private"
  provider = "aws.dev"

  tags {
    Name        = "WAF ALB Access Logs"
    Environment = "Dev"
  }
}

resource "aws_cloudformation_stack" "dev_waf" {
  name     = "waf-alb-stack"
  provider = "aws.dev"

  parameters {
    AccessLogBucket                        = "${aws_s3_bucket.dev_access_log_bucket.id}"
    SqlInjectionProtectionParam            = "yes"
    CrossSiteScriptingProtectionParam      = "yes"
    ActivateHttpFloodProtectionParam       = "yes"
    ActivateScansProbesProtectionParam     = "yes"
    ActivateReputationListsProtectionParam = "yes"
    ActivateBadBotProtectionParam          = "yes"
    SendAnonymousUsageData                 = "no"
    RequestThreshold                       = 200
    ErrorThreshold                         = 50
    WAFBlockPeriod                         = 240
  }

  disable_rollback = true

  capabilities = ["CAPABILITY_IAM"]

  template_body = "${file("aws-waf-security-automations-alb.template")}"
}
