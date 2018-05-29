variable mgmt_alb_name {
  type    = "string"
  default = "mgmt-alb"
}

variable internal_mgmt_alb {
  default = true
}

variable idle_timeout {
  default = 60
}

variable mgmt_alb_tg_name {
  type    = "string"
  default = "mgmt-alb-tg"
}

variable mgmt_alb_cert_name {
  type    = "string"
  default = "mgmt-alb-cert"
}

variable mgmt_alb_cert_file {
  type    = "string"
  default = "mgmt_alb_cert.pem"
}

variable mgmt_alb_key_file {
  type    = "string"
  default = "mgmt_alb_key.pem"
}

variable env_alb_name {
  type    = "string"
  default = "env-alb"
}

variable internal_env_alb {
  type    = "string"
  default = true
}

variable env_alb_tg_name {
  type    = "string"
  default = "env-alb-tg"
}

variable env_alb_cert_name {
  type    = "string"
  default = "env-alb-cert"
}

variable env_alb_cert_file {
  type    = "string"
  default = "env_alb_cert.pem"
}

variable env_alb_key_file {
  type    = "string"
  default = "env_alb_key.pem"
}

variable gsa_internal_cidr_block {
  type        = "string"
  description = "CIDR block for ALB security group ingress.  Required."
}
