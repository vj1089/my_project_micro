# Provider configuration for Security Group Module

# AWS Provider with default tags
provider "aws" {
  default_tags {
    tags = local.resource_tags
  }
}