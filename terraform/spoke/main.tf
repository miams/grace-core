data "aws_subnet" "selected" {
  id = "${var.gateway_subnet_ids[0]}"
}

resource "aws_route_table" "Priv-Route" {
  vpc_id           = "${data.aws_subnet.selected.vpc_id}"
  propagating_vgws = ["${aws_vpn_gateway.Transit-Spoke-VGW.id}"]

  tags {
    Name = "Priv-Route"
  }
}

resource "aws_route_table_association" "route_asso" {
  count = "${length(var.gateway_subnet_ids)}"

  subnet_id      = "${var.gateway_subnet_ids[count.index]}"
  route_table_id = "${aws_route_table.Priv-Route.id}"
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
