variable "role_arn" {
  type = "string"
}

provider "aws" {
  assume_role {
    role_arn = "${var.role_arn}"
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}
