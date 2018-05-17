resource "aws_organizations_organization" "org" {}

data "aws_s3_bucket_object" "scp" {
  bucket = "${var.bucket}"
  key    = "service_control_policy.json"
}

resource "aws_organizations_policy" "ise_approved" {
  name    = "ise_approved"
  content = "${data.aws_s3_bucket_object.scp.body}"
}

resource "aws_organizations_policy_attachment" "tenants" {
  policy_id = "${aws_organizations_policy.ise_approved.id}"

  # Organizational Unit: Tenants
  # hard-coded while waiting for https://github.com/terraform-providers/terraform-provider-aws/pull/4207
  target_id = "ou-bgtv-tu73r6dm"
}

module "master_budget" {
  source = "../budget"

  name         = "master"
  budget_limit = "3000"
}
