terraform {
  backend "s3" {
    bucket         = "weather-wise-bucket"
    key            = "weather-app.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "weather-wise-tf-state-lock"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "~>4.67.0"
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}

data "aws_region" "current" {}
