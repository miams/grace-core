# AWS GuardDuty

Module is for configuring AWS GuardDuty in single AWS account or multiple AWS accounts with GuardDuty member account. This configuration also feeds in guardduty threat lists from FireEye Isight Threat intelligence. 

## Module Inputs

List of variables in module . Refer to var.tf for full list.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| s3_bucket_name | S3 bucket name used for storing Threat File | string | | yes |
| s3_bucket_name_key| Key name for threat file  | string |  | yes |
| aws_guardduty_member_account_number| Member account number | string | 123456789012 | yes (If adding member account) |
| aws_guardduty_member_account_email |Member account root email address| string | required@example.com | yes (If adding member account) |

## Implementation Steps

1. Call module passing all variable . Example below

```
module "tenant_aws_guardduty" {
  source = "../awsguardduty/"

s3_bucket_name = "tenants3bucket"
s3_bucket_name_key = "guardduty/fireeyethreatlist.txt"
#aws_guardduty_member_account_number = "123456789012"
#aws_guardduty_member_account_email = "required@example.com"
}
 ```

## To Do
Identify how can we download FireEye Isight Threat intelligence file and write lambda to download and put file in central bucket. This needs to happen only in master account. Member account inherit threat list.
