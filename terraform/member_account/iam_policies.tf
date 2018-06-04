resource "aws_iam_policy" "GRACE_tenant_Admins_Policy" {
  name        = "GRACE_tenant_Admins_Policy"
  path        = "/"
  description = "GRACE_tenant_Admins_Policy"
  policy      = "${file("${path.module}/iam_policy_files/admin_policy.json")}"
}

resource "aws_iam_policy" "GRACE_tenant_Power_User_Policy" {
  name        = "GRACE_tenant_Power_User_Policy"
  path        = "/"
  description = "GRACE_tenant_Power_User_Policy"
  policy      = "${file("${path.module}/iam_policy_files/power_user_policy.json")}"
}

resource "aws_iam_policy" "GRACE_tenant_View_Only_Policy1" {
  name        = "GRACE_tenant_View_Only_Policy1"
  path        = "/"
  description = "GRACE_tenant_View_Only_Policy1"
  policy      = "${file("${path.module}/iam_policy_files/view_policy1.json")}"
}

resource "aws_iam_policy" "GRACE_tenant_View_Only_Policy2" {
  name        = "GRACE_tenant_View_Only_Policy2"
  path        = "/"
  description = "GRACE_tenant_View_Only_Policy2"
  policy      = "${file("${path.module}/iam_policy_files/view_policy2.json")}"
}

resource "aws_iam_policy" "GRACE_tenant_View_Only_Policy3" {
  name        = "GRACE_tenant_View_Only_Policy3"
  path        = "/"
  description = "GRACE_tenant_View_Only_Policy3"
  policy      = "${file("${path.module}/iam_policy_files/view_policy3.json")}"
}

resource "aws_iam_role_policy_attachment" "grace_tenant_admins_policy_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.tenant_admin_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_tenant_Admins_Policy.arn}"
}

resource "aws_iam_role_policy_attachment" "grace_tenant_power_user_policy_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.tenant_power_user_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_tenant_Power_User_Policy.arn}"
}

resource "aws_iam_role_policy_attachment" "grace_tenant_view_only_policy1_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.tenant_view_only_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_tenant_View_Only_Policy1.arn}"
}

resource "aws_iam_role_policy_attachment" "grace_tenant_view_only_policy2_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.tenant_view_only_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_tenant_View_Only_Policy2.arn}"
}

resource "aws_iam_role_policy_attachment" "grace_tenant_view_only_policy3_attachment" {
  count      = "${var.create_iam_roles == "true" ? 1 : 0}"
  role       = "${aws_iam_role.tenant_view_only_role.name}"
  policy_arn = "${aws_iam_policy.GRACE_tenant_View_Only_Policy3.arn}"
}
