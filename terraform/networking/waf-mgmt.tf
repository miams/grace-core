resource "aws_s3_bucket" "mgmt_access_log_bucket" {
  bucket        = "${var.mgmt_access_log_bucket}"
  acl           = "private"
  provider      = "aws.mgmt"
  force_destroy = true

  tags {
    Name        = "WAF ALB Access Logs"
    Environment = "Management"
  }
}

# Policy to allow ALB in us-east-1 region to access ALB
resource "aws_s3_bucket_policy" "mgmt_access_log_bucket_policy" {
  bucket   = "${aws_s3_bucket.mgmt_access_log_bucket.id}"
  provider = "aws.mgmt"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${var.mgmt_access_log_bucket}/*",
            "Principal": {
                "AWS": [
                    "${var.aws_alb_service_account}"
                ]
            }
        }
    ]
}
POLICY
}

resource "aws_cloudformation_stack" "mgmt_waf" {
  name     = "waf-alb-stack"
  provider = "aws.mgmt"

  parameters {
    AccessLogBucket                        = "${aws_s3_bucket.mgmt_access_log_bucket.id}"
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
