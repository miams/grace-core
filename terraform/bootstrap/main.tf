variable "bucket" {
  type = "string"
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
