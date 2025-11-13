# Extending the Multi-Resource Framework

This guide explains how to add new AWS resource types to the framework. The architecture is designed to make adding new resources straightforward and consistent.

> **💡 Note**: This guide applies to both Terraform and OpenTofu - the HCL syntax is identical for both tools.

## 🏗️ Architecture Overview

The framework follows a simple pattern:

```
resources.yaml  →  main.tf  →  Module  →  outputs.tf
    (Config)      (Orchestration) (Implementation) (Results)
```

## 📝 Step-by-Step: Adding a New Resource Type

Let's walk through adding **EKS (Elastic Kubernetes Service)** as an example.

### Step 1: Define YAML Structure

Add the resource structure to `resources.yaml`:

```yaml
# ============================================
# EKS Clusters
# ============================================
eks_clusters:
  main-cluster:
    enabled: true  # Set to false initially to test without deploying
    cluster_name: "app-eks-cluster"
    cluster_version: "1.28"
    
    # VPC Configuration
    subnet_ids:
      - "subnet-eks-1"
      - "subnet-eks-2"
      - "subnet-eks-3"
    
    # Endpoint Access
    endpoint_private_access: true
    endpoint_public_access: false
    
    # Node Groups
    node_groups:
      - name: "app-nodes"
        instance_types: ["t3.large", "t3.xlarge"]
        desired_size: 3
        min_size: 2
        max_size: 5
        disk_size: 100
        labels:
          workload: "application"
      
      - name: "spot-nodes"
        instance_types: ["t3.large"]
        capacity_type: "SPOT"
        desired_size: 2
        min_size: 1
        max_size: 4
    
    # Add-ons
    addons:
      - name: "vpc-cni"
        version: "latest"
      - name: "coredns"
        version: "latest"
    
    # Logging
    enabled_cluster_log_types:
      - "api"
      - "audit"
      - "authenticator"
    
    # Tags (merged with common_tags)
    tags:
      Name: "app-eks-cluster"
      BPO: "Platform Team"
      compliance: "GxP"
      RPO: 12
      RTO: 12
      application: "Kubernetes"
      tier: "orchestration"
```

### Step 2: Update locals in main.tf

Add EKS extraction and filtering to the locals block:

```terraform
locals {
  # ... existing code ...
  
  # Extract EKS section
  eks_clusters = try(local.config.eks_clusters, {})
  
  # Filter enabled EKS clusters
  enabled_eks = { for k, v in local.eks_clusters : k => v if try(v.enabled, true) }
  
  # Merge tags
  merged_eks_configs = {
    for k, v in local.enabled_eks : k => merge(v, {
      tags = merge(local.common.common_tags, try(v.tags, {}))
    })
  }
}
```

### Step 3: Create Module Block in main.tf

Add the module block (can start commented out):

```terraform
# ============================================
# EKS Clusters
# ============================================
module "eks_clusters" {
  for_each = local.merged_eks_configs
  
  source = "../../eks"  # Point to your EKS module
  
  # Basic configuration
  cluster_name    = each.value.cluster_name
  cluster_version = each.value.cluster_version
  
  # Networking
  region     = local.common.region
  vpc_id     = local.common.vpc_id
  subnet_ids = each.value.subnet_ids
  
  # Endpoint access
  endpoint_private_access = try(each.value.endpoint_private_access, true)
  endpoint_public_access  = try(each.value.endpoint_public_access, false)
  
  # Node groups
  node_groups = try(each.value.node_groups, [])
  
  # Add-ons
  cluster_addons = try(each.value.addons, [])
  
  # Logging
  enabled_cluster_log_types = try(each.value.enabled_cluster_log_types, [])
  
  # Tags
  it_owner    = try(each.value.tags.it_owner, local.common.common_tags.it_owner)
  BPO         = try(each.value.tags.BPO, "Default BPO")
  compliance  = try(each.value.tags.compliance, "Non-GxP")
  RPO         = try(each.value.tags.RPO, 24)
  RTO         = try(each.value.tags.RTO, 24)
  application = try(each.value.tags.application, "Default")
  environment = try(each.value.tags.environment, local.common.environment)
  department  = try(each.value.tags.department, local.common.common_tags.department)
  
  # Additional EKS-specific settings
  # ... add more as needed based on your module
}
```

### Step 4: Add Outputs

Add outputs to `outputs.tf`:

```terraform
# ============================================
# EKS Cluster Outputs
# ============================================
output "eks_clusters" {
  description = "Details of all deployed EKS clusters"
  value = {
    for k, v in module.eks_clusters : k => {
      cluster_name     = v.cluster_name
      cluster_id       = v.cluster_id
      cluster_arn      = v.cluster_arn
      cluster_endpoint = v.cluster_endpoint
      cluster_version  = v.cluster_version
      cluster_status   = v.cluster_status
      
      # OIDC provider for service accounts
      oidc_provider_arn = try(v.oidc_provider_arn, null)
      
      # Node groups
      node_groups = try(v.node_groups, {})
    }
  }
}

output "eks_cluster_endpoints" {
  description = "Map of EKS cluster keys to endpoints"
  value       = { for k, v in module.eks_clusters : k => v.cluster_endpoint }
}

output "eks_cluster_names" {
  description = "List of EKS cluster names"
  value       = [for k, v in module.eks_clusters : v.cluster_name]
}
```

### Step 5: Update Deployment Summary

Update the `deployment_summary` output in `outputs.tf`:

```terraform
output "deployment_summary" {
  description = "High-level summary of all deployed resources"
  value = {
    # ... existing fields ...
    
    # Add EKS count
    eks_count = length(module.eks_clusters)
    
    # Add to resource names
    eks_clusters = [for k, v in module.eks_clusters : v.cluster_name]
  }
}
```

### Step 6: Add Feature Flag (Optional)

Add a feature flag in `variables.tf` (if desired):

```terraform
variable "enable_eks_deployment" {
  type        = bool
  description = "Master switch to enable/disable all EKS deployments"
  default     = true
}
```

Then update the locals in `main.tf`:

```terraform
locals {
  # Apply feature flag
  enabled_eks = var.enable_eks_deployment ? {
    for k, v in local.eks_clusters : k => v if try(v.enabled, true)
  } : {}
}
```

## 📦 Resource Type Templates

Here are templates for common AWS resources:

### ECS (Elastic Container Service)

```yaml
ecs_clusters:
  app-cluster:
    enabled: true
    cluster_name: "app-ecs-cluster"
    
    capacity_providers:
      - "FARGATE"
      - "FARGATE_SPOT"
    
    default_capacity_provider_strategy:
      - capacity_provider: "FARGATE_SPOT"
        weight: 1
        base: 0
    
    services:
      - name: "web-service"
        task_definition: "web-task:latest"
        desired_count: 2
        launch_type: "FARGATE"
        
        network_configuration:
          subnets:
            - "subnet-ecs-1"
            - "subnet-ecs-2"
          security_groups:
            - "sg-ecs-tasks"
        
        load_balancer:
          target_group_arn: "arn:aws:elasticloadbalancing:..."
          container_name: "web"
          container_port: 80
    
    tags:
      Name: "app-ecs-cluster"
```

### EFS (Elastic File System)

```yaml
efs_filesystems:
  shared-storage:
    enabled: true
    name: "app-shared-storage"
    
    performance_mode: "generalPurpose"  # or "maxIO"
    throughput_mode: "bursting"         # or "provisioned"
    provisioned_throughput_in_mibps: 100  # if throughput_mode = provisioned
    
    encrypted: true
    kms_key_id: "arn:aws:kms:..."  # Optional
    
    lifecycle_policy:
      transition_to_ia: "AFTER_30_DAYS"
      transition_to_archive: "AFTER_90_DAYS"
    
    mount_targets:
      - subnet_id: "subnet-app-1"
        security_groups: ["sg-efs"]
      - subnet_id: "subnet-app-2"
        security_groups: ["sg-efs"]
    
    access_points:
      - name: "app-data"
        path: "/app/data"
        posix_user:
          uid: 1000
          gid: 1000
        root_directory:
          path: "/app/data"
          creation_info:
            owner_uid: 1000
            owner_gid: 1000
            permissions: "0755"
    
    tags:
      Name: "app-shared-storage"
```

### Lambda Functions

```yaml
lambda_functions:
  api-handler:
    enabled: true
    function_name: "api-handler"
    
    runtime: "python3.11"
    handler: "index.lambda_handler"
    memory_size: 512
    timeout: 30
    
    # Code deployment
    deployment:
      type: "s3"  # or "zip" or "image"
      s3_bucket: "lambda-deployments"
      s3_key: "api-handler/v1.0.0.zip"
      # OR for container images:
      # image_uri: "123456789012.dkr.ecr.us-west-2.amazonaws.com/api-handler:latest"
    
    # Environment variables
    environment_variables:
      DB_HOST: "mysql-primary.endpoint"  # Can reference RDS from YAML
      DB_NAME: "appdb"
      ENV: "prod"
      LOG_LEVEL: "INFO"
    
    # VPC Configuration (optional)
    vpc_config:
      subnet_ids:
        - "subnet-lambda-1"
        - "subnet-lambda-2"
      security_group_ids:
        - "sg-lambda"
    
    # IAM Role
    execution_role_arn: "arn:aws:iam::123456789012:role/lambda-execution"
    
    # Triggers
    triggers:
      - type: "api_gateway"
        api_id: "abc123"
        route: "POST /api/handler"
      
      - type: "cloudwatch_event"
        schedule_expression: "rate(5 minutes)"
    
    # Layers
    layers:
      - "arn:aws:lambda:us-west-2:123456789012:layer:common-libs:1"
    
    tags:
      Name: "api-handler"
```

### S3 Buckets

```yaml
s3_buckets:
  app-data:
    enabled: true
    bucket_name: "app-data-prod-${account_id}"  # ${account_id} replaced at runtime
    
    versioning: true
    
    encryption:
      sse_algorithm: "AES256"  # or "aws:kms"
      kms_key_id: "arn:aws:kms:..."  # if using KMS
    
    lifecycle_rules:
      - id: "archive-old-data"
        enabled: true
        prefix: "logs/"
        transitions:
          - days: 30
            storage_class: "STANDARD_IA"
          - days: 90
            storage_class: "GLACIER"
        expiration:
          days: 365
      
      - id: "cleanup-temp"
        enabled: true
        prefix: "temp/"
        expiration:
          days: 7
    
    # Access control
    public_access_block:
      block_public_acls: true
      block_public_policy: true
      ignore_public_acls: true
      restrict_public_buckets: true
    
    # Bucket policy (optional)
    bucket_policy:
      allow_cloudfront: true
      cloudfront_oai: "E123456789ABCD"
    
    # CORS (optional)
    cors_rules:
      - allowed_methods: ["GET", "HEAD"]
        allowed_origins: ["https://app.example.com"]
        allowed_headers: ["*"]
        max_age_seconds: 3600
    
    # Replication (optional)
    replication:
      enabled: true
      destination_bucket: "app-data-replica"
      destination_region: "us-east-1"
    
    tags:
      Name: "app-data-bucket"
```

### DynamoDB Tables

```yaml
dynamodb_tables:
  user-sessions:
    enabled: true
    table_name: "user-sessions"
    
    billing_mode: "PAY_PER_REQUEST"  # or "PROVISIONED"
    # read_capacity: 5   # if PROVISIONED
    # write_capacity: 5  # if PROVISIONED
    
    hash_key: "session_id"
    range_key: "timestamp"  # Optional
    
    attributes:
      - name: "session_id"
        type: "S"  # String
      - name: "timestamp"
        type: "N"  # Number
      - name: "user_id"
        type: "S"
    
    global_secondary_indexes:
      - name: "user-index"
        hash_key: "user_id"
        range_key: "timestamp"
        projection_type: "ALL"
        # read_capacity: 5   # if PROVISIONED
        # write_capacity: 5  # if PROVISIONED
    
    ttl:
      enabled: true
      attribute_name: "expires_at"
    
    point_in_time_recovery:
      enabled: true
    
    stream:
      enabled: true
      view_type: "NEW_AND_OLD_IMAGES"
    
    encryption:
      enabled: true
      kms_key_arn: "arn:aws:kms:..."
    
    tags:
      Name: "user-sessions"
```

## 🎯 Best Practices

### 1. Use Sensible Defaults

Use `try()` with defaults for optional fields:

```terraform
performance_mode = try(each.value.performance_mode, "generalPurpose")
encrypted        = try(each.value.encrypted, true)
```

### 2. Validate Required Fields

For required fields, don't use `try()` - let it fail if missing:

```terraform
cluster_name = each.value.cluster_name  # Required - will fail if not present
```

### 3. Support Resource References

Allow resources to reference each other:

```yaml
lambda_functions:
  processor:
    environment_variables:
      DB_ENDPOINT: "${rds.mysql-primary.endpoint}"  # Reference RDS
      BUCKET_NAME: "${s3.app-data.bucket_name}"     # Reference S3
```

In `main.tf`:
```terraform
environment_variables = merge(
  try(each.value.environment_variables, {}),
  {
    # Resolve references
    DB_ENDPOINT = try(
      module.rds_instances[each.value.rds_reference].endpoint,
      each.value.environment_variables.DB_ENDPOINT
    )
  }
)
```

### 4. Document YAML Structure

Add comments in `resources.yaml` explaining each field:

```yaml
eks_clusters:
  main-cluster:
    cluster_name: "app-eks-cluster"  # Name of the EKS cluster (required)
    cluster_version: "1.28"           # Kubernetes version (required)
    # ...
```

### 5. Test Incrementally

1. Add YAML structure with `enabled: false`
2. Add module block (commented out)
3. Create/verify the module exists
4. Uncomment module block
5. Test with `enabled: true` on one resource
6. Validate outputs
7. Document and commit

## 📚 Module Creation Guidelines

When creating a new module for use with this framework:

### Module Structure

```
module-name/
├── main.tf          # Resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── datasource.tf    # Data sources
├── locals.tf        # Local values
└── README.md        # Module documentation
```

### Variable Naming Convention

Use consistent naming:

```terraform
# Good
variable "cluster_name" {}
variable "cluster_version" {}
variable "node_groups" {}

# Avoid
variable "name" {}  # Too generic
variable "eks_cluster_name" {}  # Redundant when module is already named eks
```

### Required Tags

All modules should accept these tag variables:

```terraform
variable "it_owner" { type = string }
variable "BPO" { type = string }
variable "compliance" { type = string }
variable "RPO" { type = number }
variable "RTO" { type = number }
variable "application" { type = string }
variable "environment" { type = string }
variable "department" { type = string }
```

### Useful Outputs

Provide comprehensive outputs:

```terraform
output "cluster_details" {
  value = {
    id       = aws_eks_cluster.this.id
    name     = aws_eks_cluster.this.name
    arn      = aws_eks_cluster.this.arn
    endpoint = aws_eks_cluster.this.endpoint
    version  = aws_eks_cluster.this.version
    # ... more useful fields
  }
}
```

## 🔄 Update Checklist

When adding a new resource type:

- [ ] Add YAML structure to `resources.yaml` (with example and `enabled: false`)
- [ ] Update `locals` in `main.tf` to extract and filter the resource
- [ ] Add merge logic for tags
- [ ] Add module block in `main.tf` (can be commented initially)
- [ ] Add outputs to `outputs.tf`
- [ ] Update `deployment_summary` output
- [ ] Add feature flag to `variables.tf` (optional)
- [ ] Test with `enabled: true`
- [ ] Update README.md with the new resource type
- [ ] Add examples to EXAMPLES.md
- [ ] Document in this EXTENDING.md

## 🤝 Need Help?

For questions about extending the framework:
- Infrastructure Team Slack: #infra-terraform
- Review existing resource implementations in `main.tf`
- Check module documentation in the parent directory

Happy extending! 🚀
