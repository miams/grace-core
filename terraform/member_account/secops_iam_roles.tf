# TODO: Set these to SECOPS assume role values
resource "aws_iam_role" "secops_admin_role" {
  count = "${var.create_iam_roles == "true" ? 1 : 0}"

  provider = "aws.child"

  name = "${var.secops_admin_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.authlanding_prod_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "secops_view_only_role" {
  count = "${var.create_iam_roles == "true" ? 1 : 0}"

  provider = "aws.child"

  name = "${var.secops_view_only_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.authlanding_prod_account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
