provider "aws" {
  # version = "~> 1.0.0"
  region  = "us-east-2"
}

provider "aws" {
  alias = "east1"
  region = "us-east-1"
}

provider "aws" {
  alias = "west1"
  region = "us-west-1"
}

provider "aws" {
  alias = "west2"
  region = "us-west-2"
}

data "aws_caller_identity" "default" {
  provider = "aws"
}

data "aws_caller_identity" "east1" {
  provider = "aws.east1"
}

data "aws_caller_identity" "west1" {
  provider = "aws.west1"
}

data "aws_caller_identity" "west2" {
  provider = "aws.west2"
}