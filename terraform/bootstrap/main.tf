variable "bucket" {
  type = "string"
}

terraform {
  backend "s3" {
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "core_config" {
  bucket = "${var.bucket}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
