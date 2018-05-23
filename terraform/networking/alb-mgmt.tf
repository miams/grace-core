#TODO: This will eventually come from a module
resource "aws_security_group" "mgmt_alb_sg" {
  name     = "Mgmt ALB Security Group"
  provider = "aws.mgmt"
  vpc_id   = "${module.vpc_mgmt.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.gsa_internal_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.gsa_internal_cidr_block}"]
  }
}

resource "aws_iam_server_certificate" "mgmt_alb_cert" {
  name             = "${var.mgmt_alb_cert_name}"
  certificate_body = "${file(var.mgmt_alb_cert_file)}"
  private_key      = "${file(var.mgmt_alb_key_file)}"
  provider         = "aws.mgmt"
}

resource "aws_alb" "mgmt_alb" {
  name            = "${var.mgmt_alb_name}"
  provider        = "aws.mgmt"
  subnets         = ["${module.vpc_mgmt.public_subnets}"]
  security_groups = ["${aws_security_group.mgmt_alb_sg.id}"]
  internal        = "${var.internal_mgmt_alb}"
  idle_timeout    = "${var.idle_timeout}"

  tags {
    Name = "${var.mgmt_alb_name}"
  }

  access_logs {
    bucket = "${aws_s3_bucket.mgmt_access_log_bucket.id}"
    prefix = "ALB-logs"
  }
}

resource "aws_alb_target_group" "mgmt_alb_tg" {
  name     = "${var.mgmt_alb_tg_name}"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${module.vpc_mgmt.vpc_id}"
  provider = "aws.mgmt"
}

resource "aws_alb_listener" "mgmt_alb_listener" {
  load_balancer_arn = "${aws_alb.mgmt_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_iam_server_certificate.mgmt_alb_cert.arn}"
  provider          = "aws.mgmt"

  default_action {
    target_group_arn = "${aws_alb_target_group.mgmt_alb_tg.arn}"
    type             = "forward"
  }
}
