data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

resource "aws_route_table" "Dev-Priv-Route" {
  vpc_id           = "${data.aws_subnet.selected.vpc_id}"
  propagating_vgws = ["${aws_vpn_gateway.Transit-Spoke-VGW.id}"]

  tags {
    Name = "Dev-Priv-Route"
  }
}

resource "aws_route_table_association" "Dev_route_asso" {
  subnet_id      = "${var.subnet_id}"
  route_table_id = "${aws_route_table.Dev-Priv-Route.id}"
}

resource "aws_vpn_gateway" "Transit-Spoke-VGW" {
  vpc_id = "${data.aws_subnet.selected.vpc_id}"

  tags {
    Name               = "Transit-Spoke-VGW"
    "transitvpc:spoke" = "true"
  }
}

resource "aws_cloudformation_stack" "Transit-Spoke-Stack" {
  name         = "Transit-Spoke-Stack"
  on_failure   = "ROLLBACK"
  capabilities = ["CAPABILITY_IAM"]

  parameters = {
    BucketName   = "${var.TransitVpcBucketName}"
    BucketPrefix = "${var.TransitVpcBucketPrefix}"
  }

  template_body = "${file("${path.module}/files/transit_vpc_poller_template.json")}"
}
