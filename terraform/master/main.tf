provider "aws" {
  version = "~> 1.17"
}

terraform {
  backend "s3" {
    region = "us-east-1"
  }
}

data "aws_caller_identity" "master" {}
