# Provider configuration for Security Group Module

# AWS Provider with default tags
provider "aws" {
  region = var.region
  default_tags {
    tags = local.resource_tags
  }
}