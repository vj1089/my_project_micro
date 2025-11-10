# Example usage of the Security Group module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Variables for the example
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "VPC ID for the security groups"
  type        = string
}

# Example 1: Web Server Security Group (CSV format)
module "web_security_group" {
  source = "../"

  region      = var.region
  name        = "web-server-sg-example"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress_rules_list = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet",
    "22,tcp,10.0.0.0/8,SSH from internal network"
  ]

  # Tagging
  application = "web-app"
  environment = "example"
  it_owner    = "DevOps Team"
  BPO         = "Infrastructure Team"
  department  = "GTS - Infrastructure & Operations"
  compliance  = "Non-GxP"

  additional_tags = {
    Example = "true"
    Tier    = "web"
  }
}

# Example 2: Database Security Group (Object format)
module "database_security_group" {
  source = "../"

  region               = var.region
  name_prefix          = "database-sg-"
  description          = "Security group for database servers"
  vpc_id               = var.vpc_id
  create_default_egress = false

  ingress_rules = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.web_security_group.security_group_id
      description              = "MySQL from web servers"
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.100.0/24"]
      description = "MySQL from admin subnet"
    }
  ]

  egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS for updates"
    }
  ]

  # Tagging
  application = "database"
  environment = "example"
  it_owner    = "Database Team"
  BPO         = "Data Management"
  department  = "GTS - Infrastructure & Operations"
  compliance  = "GxP"

  additional_tags = {
    Example     = "true"
    Tier        = "database"
    Backup      = "daily"
    Criticality = "high"
  }
}

# Example 3: Application Load Balancer Security Group
module "alb_security_group" {
  source = "../"

  region      = var.region
  name        = "alb-sg-example"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress_rules_list = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet"
  ]

  # Tagging
  application = "load-balancer"
  environment = "example"
  it_owner    = "Network Team"
  BPO         = "Infrastructure Team"
  department  = "GTS - Infrastructure & Operations"
  compliance  = "Non-GxP"

  additional_tags = {
    Example = "true"
    Tier    = "load-balancer"
  }
}

# Outputs
output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.web_security_group.security_group_id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.database_security_group.security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.alb_security_group.security_group_id
}

output "all_security_groups" {
  description = "All created security groups"
  value = {
    web = {
      id   = module.web_security_group.security_group_id
      name = module.web_security_group.security_group_name
      arn  = module.web_security_group.security_group_arn
    }
    database = {
      id   = module.database_security_group.security_group_id
      name = module.database_security_group.security_group_name
      arn  = module.database_security_group.security_group_arn
    }
    alb = {
      id   = module.alb_security_group.security_group_id
      name = module.alb_security_group.security_group_name
      arn  = module.alb_security_group.security_group_arn
    }
  }
}