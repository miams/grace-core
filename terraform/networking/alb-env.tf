#TODO: This will eventually come from a module
resource "aws_security_group" "env_alb_sg" {
  name     = "Mgmt ALB Security Group"
  provider = "aws.env"
  vpc_id   = "${module.vpc_env.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.gsa_internal_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["${
      concat(
        module.vpc_env.private_subnets_cidr_blocks,
        module.vpc_env.public_subnets_cidr_blocks
      )
    }"]
  }
}

resource "aws_iam_server_certificate" "env_alb_cert" {
  name             = "${var.env_alb_cert_name}"
  certificate_body = "${file(var.env_alb_cert_file)}"
  private_key      = "${file(var.env_alb_key_file)}"
  provider         = "aws.env"
}

resource "aws_alb" "env_alb" {
  name            = "${var.env_alb_name}"
  provider        = "aws.env"
  subnets         = ["${module.vpc_env.public_subnets}"]
  security_groups = ["${aws_security_group.env_alb_sg.id}"]
  internal        = "${var.internal_env_alb}"
  idle_timeout    = "${var.idle_timeout}"

  tags {
    Name = "${var.env_alb_name}"
  }

  access_logs {
    bucket = "${aws_s3_bucket.env_access_log_bucket.id}"
    prefix = "ALB-logs"
  }
}

resource "aws_alb_target_group" "env_alb_tg" {
  name     = "${var.env_alb_tg_name}"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${module.vpc_env.vpc_id}"
  provider = "aws.env"
}

resource "aws_alb_listener" "env_alb_listener" {
  load_balancer_arn = "${aws_alb.env_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_iam_server_certificate.env_alb_cert.arn}"
  provider          = "aws.env"

  default_action {
    target_group_arn = "${aws_alb_target_group.env_alb_tg.arn}"
    type             = "forward"
  }
}
