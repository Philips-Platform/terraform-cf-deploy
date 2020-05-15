terraform {
  backend "s3" {
    bucket = "philips-terraform-state-management"
    key    = "app-deployment/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}
