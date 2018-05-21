provider "aws" {
  profile = "${var.profile}"
  region  = "${var.default_region}"
}

resource "aws_vpc" "Tetant-A-Dev-Demo" {
  cidr_block = "10.172.246.0/24"

  tags {
    Name = "Tetant-A-Dev"
  }
}

resource "aws_subnet" "Dev_priv_subnet" {
  vpc_id                  = "${aws_vpc.Tetant-A-Dev-Demo.id}"
  cidr_block              = "10.172.246.128/25"
  map_public_ip_on_launch = "false"

  tags {
    Name = "DevPriv-Subnet"
  }
}

resource "aws_route_table" "Dev-Priv-Route" {
  vpc_id           = "${aws_vpc.Tetant-A-Dev-Demo.id}"
  propagating_vgws = ["${aws_vpn_gateway.Transit-Spoke-VGW.id}"]

  tags {
    Name = "Dev-Priv-Route"
  }
}

resource "aws_route_table_association" "Dev_route_asso" {
  subnet_id      = "${aws_subnet.Dev_priv_subnet.id}"
  route_table_id = "${aws_route_table.Dev-Priv-Route.id}"
}

resource "aws_vpn_gateway" "Transit-Spoke-VGW" {
  vpc_id = "${aws_vpc.Tetant-A-Dev-Demo.id}"

  tags {
    Name               = "Transit-Spoke-VGW"
    "transitvpc:spoke" = "true"
  }
}

resource "aws_security_group" "Dev_Tcp" {
  vpc_id      = "${aws_vpc.Tetant-A-Dev-Demo.id}"
  name        = "Dev_Tcp"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Dev_Tcp"
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

  template_body = "${file("${path.module}/transit-vpc-Spoke.template")}"
}

resource "aws_instance" "Dev_jump_Box" {
  ami                    = "ami-f973ab84"
  instance_type          = "t2.micro"
  key_name               = "manoj-gsa-devsecops-test3-useast"
  vpc_security_group_ids = ["${aws_security_group.Dev_Tcp.id}"]
  subnet_id              = "${aws_subnet.Dev_priv_subnet.id}"

  tags {
    "Name" = "Dev_jump_Box"
  }
}
