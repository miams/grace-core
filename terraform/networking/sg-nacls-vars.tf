# Env VPC variables

variable "vpc_env_set_default_ingress_https_rule" {
  type    = "string"
  default = "true"
}

variable "vpc_env_set_default_ingress_rdp_ssh_rule" {
  type    = "string"
  default = "true"
}

variable "vpc_env_set_default_egress_rule" {
  type    = "string"
  default = "true"
}

variable "vpc_env_set_default_public_nacl" {
  type    = "string"
  default = "true"
}

variable "vpc_env_set_default_private_nacl" {
  type    = "string"
  default = "true"
}

variable "vpc_env_ingress_https_sg_name" {
  type = "string"
}

variable "vpc_env_ingress_https_cidr" {
  default = "0.0.0.0/0"
  type    = "string"
}

variable "vpc_env_ec2_management_sg_name" {
  type    = "string"
  default = "env_ec2_management_sg"
}

variable "vpc_env_ec2_egress_on_prem_sg_name" {
  type = "string"
}

variable "env_ec2_egress_on_prem_smtp_cidrs" {
  type = "list"
}

variable "env_ec2_egress_on_prem_all_traffic_cidrs" {
  type = "list"
}

variable "env_sg_ingress_rdp_port" {
  type    = "string"
  default = "3389"
}

variable "env_sg_ingress_rdp_protocol" {
  type    = "string"
  default = "tcp"
}

variable "env_sg_ingress_rdp_cidrs" {
  type = "list"
}

variable "env_sg_ingress_ssh_port" {
  type    = "string"
  default = "22"
}

variable "env_sg_ingress_ssh_protocol" {
  type    = "string"
  default = "tcp"
}

variable "env_sg_ingress_ssh_cidrs" {
  type = "list"
}

# Management VPC variables
variable "vpc_mgmt_set_default_ingress_rdp_ssh_rule" {
  type    = "string"
  default = "true"
}

variable "vpc_mgmt_set_default_egress_rule" {
  type    = "string"
  default = "true"
}

variable "vpc_mgmt_set_default_private_nacl" {
  type    = "string"
  default = "true"
}

variable "vpc_mgmt_ec2_management_sg_name" {
  type    = "string"
  default = "mgmt_ec2_management_sg"
}

variable "mgmt_sg_ingress_rdp_port" {
  type    = "string"
  default = "3389"
}

variable "mgmt_sg_ingress_rdp_protocol" {
  type    = "string"
  default = "tcp"
}

variable "mgmt_sg_ingress_rdp_cidrs" {
  type = "list"
}

variable "mgmt_sg_ingress_ssh_port" {
  type    = "string"
  default = "22"
}

variable "mgmt_sg_ingress_ssh_protocol" {
  type    = "string"
  default = "tcp"
}

variable "mgmt_sg_ingress_ssh_cidrs" {
  type = "list"
}

variable "mgmt_private_nacl_ingress_cidrs" {
  type = "list"
}

variable "mgmt_private_nacl_egress_cidrs" {
  type = "list"
}

variable "vpc_mgmt_ec2_egress_on_prem_sg_name" {
  type = "string"
}

variable "mgmt_ec2_egress_on_prem_smtp_cidrs" {
  type = "list"
}

variable "mgmt_ec2_egress_on_prem_all_traffic_cidrs" {
  type = "list"
}
