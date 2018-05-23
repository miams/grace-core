resource "aws_alb" "mgmt_alb" {
  name            = "${var.mgmt_alb_name}"
  provider        = "aws.mgmt"
  subnets         = ["${split(",", var.mgmt_alb_subnets)}"]
  security_groups = ["${split(",", var.mgmt_alb_security_groups)}"]
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
