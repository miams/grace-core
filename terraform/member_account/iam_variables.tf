variable "tenant_admin_role_name" {
  type    = "string"
  default = "GRACE_Tenant_Admin_Role"
}

variable "tenant_power_user_role_name" {
  type    = "string"
  default = "GRACE_Tenant_Power_User_Role"
}

variable "tenant_view_only_role_name" {
  type    = "string"
  default = "GRACE_Tenant_View_Only_Role"
}

variable "tenant_admin_iam_role_list" {
  type    = "list"
  default = [""]
}

variable "tenant_poweruser_iam_role_list" {
  type    = "list"
  default = [""]
}

variable "tenant_viewonly_iam_role_list" {
  type    = "list"
  default = [""]
}
