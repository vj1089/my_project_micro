terraform {
  # Compatible with both Terraform 1.0+ and OpenTofu 1.6+
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Works with both Terraform and OpenTofu
      version = "~> 5.0"
    }
  }
  
  # Backend configuration for remote state
  # Uncomment and configure for use with Harness
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "multi-resource/terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  #   
  #   # Optional: Use different state file per environment/workspace
  #   # workspace_key_prefix = "multi-resource"
  # }
}

# AWS Provider Configuration
provider "aws" {
  region = try(local.config.common.region, "us-west-2")
  
  # Default tags applied to ALL AWS resources
  default_tags {
    tags = merge(
      try(local.config.common.common_tags, {}),
      var.common_tags_override,
      {
        DeploymentId  = var.deployment_id != "" ? var.deployment_id : "manual"
        DeployedBy    = var.deployed_by
        DeployedAt    = var.deployment_timestamp != "" ? var.deployment_timestamp : timestamp()
        ManagedBy     = "Terraform"
        ConfigSource  = "YAML"
      }
    )
  }
  
  # Use assume role if needed for Harness cross-account deployments
  # assume_role {
  #   role_arn = "arn:aws:iam::ACCOUNT_ID:role/HarnessDeploymentRole"
  # }
}
