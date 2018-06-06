# TODO: Need to find a way to dynamically build the ARN just from a list of usernames provided below, so the principal ends up with a list of ARNs and not a list of usernames - can I use a null_resource to send in a username and have it return an ARN with the username and authlanding_account_id (see authlanding_account.tf for possible example of building a list and figure out how to get the full list of ARNs into the sts_assume_role policy on IAM creation - ideas: element, concat, count, etc.
# https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
# THIS LOOKS LIKE A WINNER (jsonencode): https://stackoverflow.com/questions/43513943/how-does-one-combine-concat-with-formatlist-in-terraform/43526664

# {
#     "Action": [
#         "s3:Get*",
#         "s3:List*"
#     ],
#    "Effect": "Allow",
#    "Resource": ${jsonencode(
#      concat(
#        formatlist("arn:aws:s3:::%s", var.data_pipeline_s3_buckets),
#        formatlist("arn:aws:s3:::%s/", var.data_pipeline_s3_buckets)
#      )
#    )}
# }

resource "aws_iam_role" "tenant_admin_role" {
  count = "${var.create_iam_roles == "true" ? 1 : 0}"

  provider = "aws.child"

  name = "${var.tenant_admin_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(concat(formatlist("arn:aws:iam::%s:user/%s", var.authlanding_prod_account_id, var.tenant_admin_iam_role_list)))}
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "tenant_power_user_role" {
  count = "${var.create_iam_roles == "true" ? 1 : 0}"

  provider = "aws.child"

  name = "${var.tenant_power_user_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(concat(formatlist("arn:aws:iam::%s:user/%s", var.authlanding_prod_account_id, var.tenant_poweruser_iam_role_list)))}
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "tenant_view_only_role" {
  count = "${var.create_iam_roles == "true" ? 1 : 0}"

  provider = "aws.child"

  name = "${var.tenant_view_only_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(concat(formatlist("arn:aws:iam::%s:user/%s", var.authlanding_prod_account_id, var.tenant_viewonly_iam_role_list)))}
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
