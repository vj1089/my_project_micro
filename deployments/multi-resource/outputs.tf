# ============================================
# Multi-Resource Deployment Outputs
# ============================================

# ============================================
# Deployment Summary
# ============================================
output "deployment_summary" {
  description = "High-level summary of all deployed resources"
  value = {
    deployment_id = var.deployment_id
    deployed_by   = var.deployed_by
    deployed_at   = var.deployment_timestamp != "" ? var.deployment_timestamp : timestamp()
    environment   = try(local.config.common.environment, "unknown")
    region        = try(local.config.common.region, "unknown")
    vpc_id        = try(local.config.common.vpc_id, "unknown")
    
    # Resource counts
    ec2_count = length(module.ec2_instances)
    rds_count = length(module.rds_instances)
    alb_count = length(module.load_balancers)
    
    # Resource names
    ec2_instances = [for k, v in module.ec2_instances : v.EC2_Details.Name]
    rds_instances = [for k, v in module.rds_instances : k]
    alb_instances = [for k, v in module.load_balancers : k]
  }
}

# ============================================
# EC2 Instance Outputs
# ============================================
output "ec2_instances" {
  description = "Details of all deployed EC2 instances"
  value = {
    for k, v in module.ec2_instances : k => {
      id         = v.EC2_Details.InstanceID
      name       = v.EC2_Details.Name
      private_ip = v.EC2_Details.IP
      sg_id      = v.EC2_Details.Instance_SG_ID
      sg_name    = v.EC2_Details.Instance_SG_Name
      os_user    = try(v.EC2_Details.os_user, "N/A")
      tags       = v.EC2_Details.Instance_Tags
    }
  }
}

output "ec2_instance_ids" {
  description = "Map of EC2 instance keys to instance IDs"
  value       = { for k, v in module.ec2_instances : k => v.EC2_Details.InstanceID }
}

output "ec2_private_ips" {
  description = "Map of EC2 instance keys to private IP addresses"
  value       = { for k, v in module.ec2_instances : k => v.EC2_Details.IP }
}

output "ec2_security_groups" {
  description = "Map of EC2 instance keys to security group IDs"
  value       = { for k, v in module.ec2_instances : k => v.EC2_Details.Instance_SG_ID }
}

# ============================================
# RDS Instance Outputs
# ============================================
output "rds_instances" {
  description = "Details of all deployed RDS instances"
  value = {
    for k, v in module.rds_instances : k => {
      # Adjust these based on your actual RDS module outputs
      # These are placeholder fields - update based on your RDS module's output structure
      identifier = k
      # endpoint   = try(v.db_instance_endpoint, "N/A")
      # arn        = try(v.db_instance_arn, "N/A")
      # Add more fields as needed from your RDS module outputs
    }
  }
  sensitive = true  # RDS details may contain sensitive info
}

output "rds_identifiers" {
  description = "List of RDS instance identifiers"
  value       = [for k, v in module.rds_instances : k]
}

# ============================================
# Load Balancer Outputs
# ============================================
output "load_balancers" {
  description = "Details of all deployed load balancers"
  value = {
    for k, v in module.load_balancers : k => {
      # Adjust these based on your actual ELB module outputs
      name = k
      # dns_name = try(v.lb_dns_name, "N/A")
      # arn      = try(v.lb_arn, "N/A")
      # zone_id  = try(v.lb_zone_id, "N/A")
      # Add more fields as needed from your ELB module outputs
    }
  }
}

output "alb_names" {
  description = "List of load balancer names"
  value       = [for k, v in module.load_balancers : k]
}

# ============================================
# Future Resource Outputs
# ============================================

# Uncomment and customize as you add more resource types

# output "eks_clusters" {
#   description = "Details of all deployed EKS clusters"
#   value = {
#     for k, v in module.eks_clusters : k => {
#       name     = v.cluster_name
#       endpoint = v.cluster_endpoint
#       version  = v.cluster_version
#     }
#   }
# }

# output "ecs_clusters" {
#   description = "Details of all deployed ECS clusters"
#   value = {
#     for k, v in module.ecs_clusters : k => {
#       name = v.cluster_name
#       arn  = v.cluster_arn
#     }
#   }
# }

# output "efs_filesystems" {
#   description = "Details of all deployed EFS file systems"
#   value = {
#     for k, v in module.efs_filesystems : k => {
#       id         = v.file_system_id
#       dns_name   = v.dns_name
#     }
#   }
# }

# output "lambda_functions" {
#   description = "Details of all deployed Lambda functions"
#   value = {
#     for k, v in module.lambda_functions : k => {
#       function_name = v.function_name
#       arn           = v.function_arn
#       invoke_arn    = v.invoke_arn
#     }
#   }
# }

# output "s3_buckets" {
#   description = "Details of all deployed S3 buckets"
#   value = {
#     for k, v in module.s3_buckets : k => {
#       bucket_name = v.bucket_name
#       arn         = v.bucket_arn
#     }
#   }
# }

# ============================================
# Outputs for Harness Integration
# ============================================

# This output can be used in Harness approval messages or notifications
output "harness_deployment_message" {
  description = "Formatted deployment message for Harness notifications"
  value = <<-EOT
    ========================================
    Multi-Resource Deployment Complete
    ========================================
    Environment: ${try(local.config.common.environment, "N/A")}
    Region: ${try(local.config.common.region, "N/A")}
    VPC: ${try(local.config.common.vpc_id, "N/A")}
    
    Resources Deployed:
    - EC2 Instances: ${length(module.ec2_instances)}
    - RDS Instances: ${length(module.rds_instances)}
    - Load Balancers: ${length(module.load_balancers)}
    
    EC2 Instances:
    ${join("\n", [for k, v in module.ec2_instances : "  - ${v.EC2_Details.Name} (${v.EC2_Details.InstanceID}) - ${v.EC2_Details.IP}"])}
    
    Deployment ID: ${var.deployment_id}
    Deployed By: ${var.deployed_by}
    ========================================
  EOT
}

# Export configuration file path for reference
output "config_file_used" {
  description = "Path to the YAML configuration file used for this deployment"
  value       = local.config_file
}

# Export enabled resource types
output "enabled_resource_types" {
  description = "List of resource types that were enabled for deployment"
  value = {
    ec2 = length(module.ec2_instances) > 0
    rds = length(module.rds_instances) > 0
    alb = length(module.load_balancers) > 0
    # Add more as modules are added
  }
}
