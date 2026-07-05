terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: store state remotely so Jenkins runs are consistent/idempotent
  # backend "s3" {
  #   bucket = "foodexpress-terraform-state"
  #   key    = "ec2/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
