# Configure the minimal Terraform version
terraform {
  required_version = ">= 1.5.6"
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}