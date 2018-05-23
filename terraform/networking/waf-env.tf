resource "aws_s3_bucket" "env_access_log_bucket" {
  bucket        = "${var.env_access_log_bucket}"
  acl           = "private"
  provider      = "aws.env"
  force_destroy = true

  tags {
    Name = "WAF ALB Access Logs"
  }
}

# Policy to allow ALB in us-east-1 region to access ALB
resource "aws_s3_bucket_policy" "env_access_log_bucket_policy" {
  bucket   = "${aws_s3_bucket.env_access_log_bucket.id}"
  provider = "aws.env"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${var.env_access_log_bucket}/*",
            "Principal": {
                "AWS": [
                    "127311923021"
                ]
            }
        }
    ]
}
POLICY
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
