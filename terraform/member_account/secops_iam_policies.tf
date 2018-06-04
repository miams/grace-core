resource "aws_iam_policy" "GRACE_SecOps_Admins_Policy" {
  name        = "GRACE_SecOps_Admins_Policy"
  path        = "/"
  description = "GRACE_SecOps_Admins_Policy"
  policy      = "${file("${path.module}/iam_policy_files/secops_admin_policy.json")}"
}

resource "aws_iam_policy" "GRACE_SecOps_View_Only_Policy" {
  name        = "GRACE_SecOps_View_Only_Policy"
  path        = "/"
  description = "GRACE_SecOps_View_Only_Policy"
  policy      = "${file("${path.module}/iam_policy_files/secops_view_only_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "grace_secops_admins_policy_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.secops_admin_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_SecOps_Admins_Policy.arn}"
}

resource "aws_iam_role_policy_attachment" "grace_secops_view_only_policy_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.secops_view_only_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_SecOps_View_Only_Policy.arn}"
}
