terraform {

  required_version = ">= 1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "s3-fp-talk-tf-backend-772350229400"
    key    = "terraform"
    region = "eu-west-1"
  }

}

provider "aws" {
  region = "eu-west-1"
}
