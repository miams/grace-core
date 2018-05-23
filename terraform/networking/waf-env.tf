resource "aws_s3_bucket" "env_access_log_bucket" {
  bucket   = "${var.env_access_log_bucket}"
  acl      = "private"
  provider = "aws.env"

  tags {
    Name        = "WAF ALB Access Logs"
    Environment = "Prod"
  }
}

resource "aws_cloudformation_stack" "env_waf" {
  name     = "waf-alb-stack"
  provider = "aws.env"

  parameters {
    AccessLogBucket                        = "${aws_s3_bucket.env_access_log_bucket.id}"
    SqlInjectionProtectionParam            = "yes"
    CrossSiteScriptingProtectionParam      = "yes"
    ActivateHttpFloodProtectionParam       = "yes"
    ActivateScansProbesProtectionParam     = "yes"
    ActivateReputationListsProtectionParam = "yes"
    ActivateBadBotProtectionParam          = "yes"
    SendAnonymousUsageData                 = "no"
    RequestThreshold                       = 2000
    ErrorThreshold                         = 50
    WAFBlockPeriod                         = 240
  }

  disable_rollback = true

  capabilities = ["CAPABILITY_IAM"]

  template_body = "${file("aws-waf-security-automations-alb.template")}"
}
