# ============================================
# Multi-Resource Deployment Variables
# ============================================

# NOTE: Terraform does not support variables in module source paths.
# To change module sources, directly edit the source paths in main.tf
# 
# For local modules:     source = "../../ec2-instance"
# For Git:              source = "git::https://github.com/org/modules.git//aws/ec2-instance?ref=v1.0.0"
# For Terraform Cloud:  source = "app.terraform.io/org/ec2-instance/aws"
# For S3:               source = "s3::https://s3.amazonaws.com/modules/ec2-instance"
#
# To switch between environments:
#   - Use different deployment directories (dev/, staging/, prod/)
#   - Each can have main.tf with appropriate module sources
#   - Share the same resources.yaml configuration

# ============================================
# Configuration File Override
# ============================================
variable "resources_config_file" {
  type        = string
  description = "Path to the YAML configuration file. Allows overriding the default resources.yaml"
  default     = ""
}

# ============================================
# Sensitive Variables (From Harness Secrets)
# ============================================

variable "rds_passwords" {
  type        = map(string)
  description = "Map of RDS instance keys to passwords. Keys should match the keys in resources.yaml"
  sensitive   = true
  default     = {}
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for EBS encryption"
  sensitive   = true
  default     = ""
}

variable "kms_key_alias_name_base" {
  type        = string
  description = "Base KMS alias name for encryption"
  default     = "alias/ebs-key"
}

variable "enable_kms_alias_lookup" {
  type        = bool
  description = "Enable KMS alias lookup for encryption keys"
  default     = false
}

# ============================================
# ACM Certificate ARNs for HTTPS Listeners
# ============================================
variable "certificate_arns" {
  type        = map(string)
  description = "Map of load balancer keys to ACM certificate ARNs for HTTPS"
  default     = {}
}

# ============================================
# Environment-Specific Overrides
# ============================================
variable "environment_override" {
  type        = string
  description = "Override the environment value from YAML (useful for multi-environment deployments)"
  default     = ""
}

variable "region_override" {
  type        = string
  description = "Override the region value from YAML"
  default     = ""
}

variable "vpc_id_override" {
  type        = string
  description = "Override the VPC ID from YAML"
  default     = ""
}

# ============================================
# Feature Flags
# ============================================
variable "enable_ec2_deployment" {
  type        = bool
  description = "Master switch to enable/disable all EC2 deployments regardless of YAML config"
  default     = true
}

variable "enable_rds_deployment" {
  type        = bool
  description = "Master switch to enable/disable all RDS deployments regardless of YAML config"
  default     = true
}

variable "enable_alb_deployment" {
  type        = bool
  description = "Master switch to enable/disable all ALB deployments regardless of YAML config"
  default     = true
}

variable "enable_eks_deployment" {
  type        = bool
  description = "Master switch to enable/disable all EKS deployments (when module is added)"
  default     = false
}

variable "enable_ecs_deployment" {
  type        = bool
  description = "Master switch to enable/disable all ECS deployments (when module is added)"
  default     = false
}

variable "enable_efs_deployment" {
  type        = bool
  description = "Master switch to enable/disable all EFS deployments (when module is added)"
  default     = false
}

variable "enable_lambda_deployment" {
  type        = bool
  description = "Master switch to enable/disable all Lambda deployments (when module is added)"
  default     = false
}

variable "enable_s3_deployment" {
  type        = bool
  description = "Master switch to enable/disable all S3 deployments (when module is added)"
  default     = false
}

# ============================================
# Common Tag Overrides
# ============================================
variable "common_tags_override" {
  type        = map(string)
  description = "Override or add additional common tags to all resources"
  default     = {}
}

# ============================================
# Deployment Metadata
# ============================================
variable "deployment_id" {
  type        = string
  description = "Unique identifier for this deployment (useful for tracking in Harness)"
  default     = ""
}

variable "deployment_timestamp" {
  type        = string
  description = "Timestamp of deployment (can be passed from Harness pipeline)"
  default     = ""
}

variable "deployed_by" {
  type        = string
  description = "User or system that triggered the deployment"
  default     = "Harness"
}
