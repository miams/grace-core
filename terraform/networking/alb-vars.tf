variable mgmt_alb_name {
  default = "mgmt-alb"
}

variable mgmt_alb_subnets {
  # Using the ids from the Terraform resources isn't working
  #default = "${module.vpc_mgmt.aws_subnet.private[0].id},${module.vpc_mgmt.aws_subnet.private[1].id}"
  default = "subnet-c3830889,subnet-34c95d3b"
}

variable mgmt_alb_security_groups {
  # TODO: Create SG(s) for ALB
  default = "sg-806a08c8"
}

variable internal_mgmt_alb {
  default = true
}

variable idle_timeout {
  default = 60
}
