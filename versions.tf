terraform {

  required_version = ">= 1.9.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.0"
    }
  }

  backend "s3" {
    bucket = "s3-fp-talk-tf-backend"
    key    = "terraform"
    region = "eu-west-3"
  }

}

provider "aws" {
  region = "eu-west-3"
}
