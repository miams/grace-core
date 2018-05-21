resource "aws_s3_bucket" "staging_access_log_bucket" {
  bucket   = "${var.staging_access_log_bucket}"
  acl      = "private"
  provider = "aws.staging"

  tags {
    Name        = "WAF ALB Access Logs"
    Environment = "Staging"
  }
}

resource "aws_cloudformation_stack" "staging_waf" {
  name     = "waf-alb-stack"
  provider = "aws.staging"

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
