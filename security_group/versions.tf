# Version constraints for Security Group Module

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Pinning aws provider to v4.x ensures the module behavior remains stable and avoids
# attribute deprecations introduced in later major provider releases. Run
# `terraform init -upgrade` in your environment to respect this pin.