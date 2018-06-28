output "account_id" {
  value = "${aws_organizations_account.child.id}"
}

output "root_arn" {
  value = "arn:aws:iam::${aws_organizations_account.child.id}:root"
}

output "tenant_admin_role_arn" {
  value = "${aws_iam_role.tenant_admin_role.arn}"
}

output "tenant_power_user_role_arn" {
  value = "${aws_iam_role.tenant_power_user_role.arn}"
}

output "tenant_view_only_role_arn" {
  value = "${aws_iam_role.tenant_view_only_role.arn}"
}

output "tenant_secops_admin_role_arn" {
  value = "${aws_iam_role.secops_admin_role.arn}"
}

output "tenant_secops_view_only_role_arn" {
  value = "${aws_iam_role.secops_view_only_role.arn}"
}
