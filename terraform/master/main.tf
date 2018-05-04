provider "aws" {
  version = "~> 1.16"
}

terraform {
  backend "s3" {
    region = "us-east-1"
  }
}
