# ============================================
# Multi-Resource Terraform Orchestration
# ============================================
# This main.tf dynamically deploys resources based on resources.yaml
# Framework is extensible - add new resource types by adding new module blocks

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================
# Read and Parse YAML Configuration
# ============================================
locals {
  # Read YAML file
  config_file = var.resources_config_file != "" ? var.resources_config_file : "${path.module}/resources.yaml"
  config      = yamldecode(file(local.config_file))
  
  # Extract common configuration
  common = local.config.common
  
  # Extract resource sections (with safe defaults)
  ec2_instances       = try(local.config.ec2_instances, {})
  rds_instances       = try(local.config.rds_instances, {})
  load_balancers      = try(local.config.load_balancers, {})
  eks_clusters        = try(local.config.eks_clusters, {})
  ecs_clusters        = try(local.config.ecs_clusters, {})
  efs_filesystems     = try(local.config.efs_filesystems, {})
  lambda_functions    = try(local.config.lambda_functions, {})
  s3_buckets          = try(local.config.s3_buckets, {})
  security_groups     = try(local.config.security_groups, {})
  cloudwatch_logs     = try(local.config.cloudwatch_log_groups, {})
  
  # Filter only enabled resources
  enabled_ec2         = { for k, v in local.ec2_instances : k => v if try(v.enabled, true) }
  enabled_rds         = { for k, v in local.rds_instances : k => v if try(v.enabled, true) }
  enabled_albs        = { for k, v in local.load_balancers : k => v if try(v.enabled, true) }
  enabled_eks         = { for k, v in local.eks_clusters : k => v if try(v.enabled, true) }
  enabled_ecs         = { for k, v in local.ecs_clusters : k => v if try(v.enabled, true) }
  enabled_efs         = { for k, v in local.efs_filesystems : k => v if try(v.enabled, true) }
  enabled_lambda      = { for k, v in local.lambda_functions : k => v if try(v.enabled, true) }
  enabled_s3          = { for k, v in local.s3_buckets : k => v if try(v.enabled, true) }
  enabled_sgs         = { for k, v in local.security_groups : k => v if try(v.enabled, true) }
  enabled_cwlogs      = { for k, v in local.cloudwatch_logs : k => v if try(v.enabled, true) }
  
  # Merge common tags with resource-specific tags
  merged_ec2_configs = {
    for k, v in local.enabled_ec2 : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_rds_configs = {
    for k, v in local.enabled_rds : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_alb_configs = {
    for k, v in local.enabled_albs : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_eks_configs = {
    for k, v in local.enabled_eks : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_ecs_configs = {
    for k, v in local.enabled_ecs : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_efs_configs = {
    for k, v in local.enabled_efs : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_lambda_configs = {
    for k, v in local.enabled_lambda : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_s3_configs = {
    for k, v in local.enabled_s3 : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_sg_configs = {
    for k, v in local.enabled_sgs : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
  
  merged_cwlog_configs = {
    for k, v in local.enabled_cwlogs : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
}

# ============================================
# EC2 Instances
# ============================================
module "ec2_instances" {
  for_each = local.merged_ec2_configs
  
  source = "${var.module_source_prefix}/ec2-instance"
  
  # Instance configuration
  instance_name     = each.value.instance_name
  ami_id            = each.value.ami_id
  app_instance_type = each.value.instance_type
  key_name          = each.value.key_name
  private_subnets   = [each.value.subnet_id]
  os_type           = try(each.value.os_type, "linux")
  root_vol_size     = try(each.value.root_vol_size, "100")
  instance_role     = try(each.value.instance_role, "AmazonSSMRoleForInstancesQuickSetup")
  
  # Security group rules
  sg_rules_ec2 = try(each.value.security_group_rules, [])
  
  # Common configuration
  region = local.common.region
  vpc_id = local.common.vpc_id
  
  # Tags
  it_owner    = try(each.value.tags.it_owner, local.common.common_tags.it_owner)
  BPO         = try(each.value.tags.BPO, "Default BPO")
  compliance  = try(each.value.tags.compliance, "Non-GxP")
  RPO         = try(each.value.tags.RPO, 24)
  RTO         = try(each.value.tags.RTO, 24)
  application = try(each.value.tags.application, "Default")
  environment = try(each.value.tags.environment, local.common.environment)
  department  = try(each.value.tags.department, local.common.common_tags.department)
  
  # KMS configuration
  kms_key_arn              = try(var.kms_key_arn, "")
  kms_key_alias_name_base  = try(var.kms_key_alias_name_base, "alias/ebs-key")
  enable_kms_alias_lookup  = try(var.enable_kms_alias_lookup, false)
}

# ============================================
# RDS Instances
# ============================================
module "rds_instances" {
  for_each = local.merged_rds_configs
  
  source = "${var.module_source_prefix}/rds"
  
  # Basic configuration (mapped to your RDS module variables)
  db_name            = each.value.identifier
  db_engine          = each.value.engine
  db_engine_version  = each.value.engine_version
  db_instance_type   = each.value.instance_class
  db_storage         = each.value.allocated_storage
  
  # Database credentials
  db_username = each.value.master_username
  db_password = try(var.rds_passwords[each.key], "CHANGE_ME")  # From Harness secrets
  
  # Networking
  region    = local.common.region
  vpc_id    = local.common.vpc_id
  subnet_id = try(each.value.subnet_ids, [])
  
  # High availability
  multi_az = try(each.value.multi_az, false)
  
  # Security group rules
  sg_rules_rds = try(each.value.security_group_rules, [])
  
  # Tags
  it_owner    = try(each.value.tags.it_owner, local.common.common_tags.it_owner)
  BPO         = try(each.value.tags.BPO, "Default BPO")
  compliance  = try(each.value.tags.compliance, "Non-GxP")
  application = try(each.value.tags.application, "Default")
  environment = try(each.value.tags.environment, local.common.environment)
  department  = try(each.value.tags.department, local.common.common_tags.department)
  
  # Optional overrides
  db_engine_minorVersion = try(each.value.engine_minor_version, "0")
  managed_by             = "Terraform-Harness"
}

# ============================================
# Application Load Balancers
# ============================================
module "load_balancers" {
  for_each = local.merged_alb_configs
  
  source = "${var.module_source_prefix}/elb"
  
  # Basic configuration (mapped to your ELB module variables)
  lb_name            = each.value.name
  lb_internal        = try(each.value.internal, false)
  load_balancer_type = try(each.value.load_balancer_type, "application")
  
  # Networking
  region     = local.common.region
  vpc_id     = local.common.vpc_id
  lb_subnets = try(each.value.subnet_ids, [])
  
  # Target group configuration
  lb_target_group_port = [try(each.value.target_group.port, 80)]
  lb_target_group_protocol = try(each.value.target_group.protocol, "HTTP")
  lb_target_type           = try(each.value.target_group.target_type, "instance")
  
  # Health check configuration
  lb_health_check = {
    path                = try(each.value.target_group.health_check.path, "/")
    interval            = try(each.value.target_group.health_check.interval, 30)
    timeout             = try(each.value.target_group.health_check.timeout, 5)
    healthy_threshold   = try(each.value.target_group.health_check.healthy_threshold, 2)
    unhealthy_threshold = try(each.value.target_group.health_check.unhealthy_threshold, 2)
    matcher             = try(each.value.target_group.health_check.matcher, "200")
  }
  lb_health_check_protocol = try(each.value.target_group.protocol, "HTTP")
  
  # Listener configuration
  lb_listener_protocol = try(each.value.listeners[0].protocol, "HTTP")
  
  # Security group rules
  sg_rules_alb = try(each.value.security_group_rules, [])
  
  # Tags
  it_owner    = try(each.value.tags.it_owner, local.common.common_tags.it_owner)
  BPO         = try(each.value.tags.BPO, "Default BPO")
  compliance  = try(each.value.tags.compliance, "Non-GxP")
  application = try(each.value.tags.application, "Default")
  environment = try(each.value.tags.environment, local.common.environment)
  department  = try(each.value.tags.department, local.common.common_tags.department)
  
  # Optional settings
  lb_enable_deletion_protection = try(each.value.enable_deletion_protection, false)
  managed_by                     = "Terraform-Harness"
}

# ============================================
# EKS Clusters (Future)
# ============================================
# Uncomment and customize when you create the EKS module
# module "eks_clusters" {
#   for_each = local.merged_eks_configs
#   
#   source = "${var.module_source_prefix}/eks"
#   
#   cluster_name    = each.value.cluster_name
#   cluster_version = each.value.cluster_version
#   vpc_id          = local.common.vpc_id
#   subnet_ids      = each.value.subnet_ids
#   
#   # Node groups
#   node_groups = try(each.value.node_groups, [])
#   
#   # Tags
#   tags = each.value.tags
# }

# ============================================
# ECS Clusters (Future)
# ============================================
# module "ecs_clusters" {
#   for_each = local.merged_ecs_configs
#   
#   source = "${var.module_source_prefix}/ecs"
#   
#   cluster_name       = each.value.cluster_name
#   capacity_providers = each.value.capacity_providers
#   
#   tags = each.value.tags
# }

# ============================================
# EFS File Systems (Future)
# ============================================
# module "efs_filesystems" {
#   for_each = local.merged_efs_configs
#   
#   source = "${var.module_source_prefix}/efs"
#   
#   name             = each.value.name
#   performance_mode = each.value.performance_mode
#   throughput_mode  = each.value.throughput_mode
#   encrypted        = each.value.encrypted
#   
#   mount_targets = each.value.mount_targets
#   
#   tags = each.value.tags
# }

# ============================================
# Lambda Functions (Future)
# ============================================
# module "lambda_functions" {
#   for_each = local.merged_lambda_configs
#   
#   source = "${var.module_source_prefix}/lambda"
#   
#   function_name = each.value.function_name
#   runtime       = each.value.runtime
#   handler       = each.value.handler
#   memory_size   = each.value.memory_size
#   timeout       = each.value.timeout
#   
#   environment_variables = each.value.environment_variables
#   
#   tags = each.value.tags
# }

# ============================================
# S3 Buckets (Future)
# ============================================
# module "s3_buckets" {
#   for_each = local.merged_s3_configs
#   
#   source = "${var.module_source_prefix}/s3"
#   
#   bucket_name = replace(each.value.bucket_name, "${account_id}", local.common.account_id)
#   versioning  = each.value.versioning
#   encryption  = each.value.encryption
#   
#   tags = each.value.tags
# }

# ============================================
# Additional Resource Types
# ============================================
# Add more module blocks as you create new modules:
# - CloudWatch Log Groups
# - SNS Topics
# - SQS Queues
# - DynamoDB Tables
# - ElastiCache Clusters
# - OpenSearch Domains
# - Route53 Zones
# - ACM Certificates
# - Secrets Manager Secrets
# - Parameter Store Parameters
# - etc.
