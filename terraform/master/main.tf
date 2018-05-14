provider "aws" {
  version = "~> 1.17"
}

terraform {
  backend "s3" {
    region = "us-east-1"
  }
}
