variable mgmt_alb_name {
  default = "mgmt-alb"
}

variable internal_mgmt_alb {
  default = true
}

variable idle_timeout {
  default = 60
}

variable mgmt_alb_tg_name {
  default = "mgmt-alb-tg"
}

variable mgmt_alb_cert_name {
  default = "mgmt-alb-cert"
}

variable mgmt_alb_cert_file {
  default = "mgmt_alb_cert.pem"
}

variable mgmt_alb_key_file {
  default = "mgmt_alb_key.pem"
}

variable env_alb_name {
  default = "env-alb"
}

variable internal_env_alb {
  default = true
}

variable env_alb_tg_name {
  default = "env-alb-tg"
}

variable env_alb_cert_name {
  default = "env-alb-cert"
}

variable env_alb_cert_file {
  default = "env_alb_cert.pem"
}

variable env_alb_key_file {
  default = "env_alb_key.pem"
}

variable gsa_internal_cidr_block {}
