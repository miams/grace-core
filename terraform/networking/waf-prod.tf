resource "aws_s3_bucket" "prod_access_log_bucket" {
  bucket   = "${var.prod_access_log_bucket}"
  acl      = "private"
  provider = "aws.prod"

  tags {
    Name        = "WAF ALB Access Logs"
    Environment = "Prod"
  }
}

resource "aws_cloudformation_stack" "prod_waf" {
  name     = "waf-alb-stack"
  provider = "aws.prod"

  parameters {
    AccessLogBucket                        = "${aws_s3_bucket.prod_access_log_bucket.id}"
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
