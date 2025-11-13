# Multi-Resource Deployment Framework

A flexible, YAML-driven Terraform framework for deploying multiple AWS resources (EC2, RDS, ALB, EKS, ECS, etc.) in a single deployment. Designed for seamless integration with Harness CI/CD.

## 🎯 Features

- **YAML-Driven Configuration**: Define all resources in a single, easy-to-read YAML file
- **Multi-Resource Support**: Deploy EC2, RDS, ALB, and easily add more resource types
- **Extensible Architecture**: Framework designed to accommodate future resource types (EKS, ECS, EFS, Lambda, S3, etc.)
- **Resource Toggling**: Enable/disable individual resources with a simple flag
- **Tag Inheritance**: Common tags automatically merged with resource-specific tags
- **Cross-Resource References**: Resources can reference each other (e.g., ALB targets EC2 instances)
- **Harness Native**: Built for Harness with secrets management and variable support
- **Environment-Aware**: Support multiple environments with different configurations

## 📁 Structure

```
multi-resource/
├── resources.yaml          # YAML configuration for all resources
├── main.tf                 # Dynamic resource orchestration
├── variables.tf            # Variable definitions
├── provider.tf             # AWS provider and backend config
├── outputs.tf              # Dynamic outputs for all resources
├── README.md               # This file
├── USAGE.md                # Detailed usage guide
└── EXTENDING.md            # Guide for adding new resource types
```

## 🚀 Quick Start

### 1. Configure Resources

Edit `resources.yaml` to define your infrastructure:

```yaml
common:
  region: "us-west-2"
  vpc_id: "vpc-abc123"
  environment: "prod"

ec2_instances:
  web-server-01:
    enabled: true
    instance_name: "web-server-01"
    ami_id: "ami-0123456789abcdef0"
    instance_type: "t3.medium"
    # ... more config

rds_instances:
  mysql-primary:
    enabled: true
    identifier: "app-mysql-primary"
    engine: "mysql"
    # ... more config

load_balancers:
  web-alb:
    enabled: true
    name: "web-tier-alb"
    # ... more config
```

### 2. Deploy with Terraform

```bash
terraform init
terraform plan
terraform apply
```

### 3. Deploy with Harness

See [HARNESS_INTEGRATION.md](./HARNESS_INTEGRATION.md) for detailed pipeline configuration.

## 📋 Supported Resource Types

| Resource Type | Status | Module Reference |
|---------------|--------|------------------|
| **EC2 Instances** | ✅ Active | `../../ec2-instance` |
| **RDS Databases** | ✅ Active | `../../rds` |
| **Application Load Balancers** | ✅ Active | `../../elb` |
| **EKS Clusters** | 🔄 Ready to implement | `../../eks` (to be created) |
| **ECS Clusters** | 🔄 Ready to implement | `../../ecs` (to be created) |
| **EFS File Systems** | 🔄 Ready to implement | `../../efs` (to be created) |
| **Lambda Functions** | 🔄 Ready to implement | `../../lambda` (to be created) |
| **S3 Buckets** | 🔄 Ready to implement | `../../s3` (to be created) |

## 🔧 Key Features Explained

### Resource Toggle

Simply set `enabled: false` to skip deployment without removing configuration:

```yaml
ec2_instances:
  web-server-01:
    enabled: false  # This instance will not be deployed
```

### Tag Inheritance

Common tags are automatically merged with resource-specific tags:

```yaml
common:
  common_tags:
    department: "Engineering"
    managed_by: "Terraform"

ec2_instances:
  web-server-01:
    tags:
      application: "WebApp"  # Merges with common_tags
```

Result: Instance gets both `department`, `managed_by`, AND `application` tags.

### Cross-Resource References

ALB can automatically target EC2 instances:

```yaml
ec2_instances:
  app-server-01:
    # ... config

load_balancers:
  internal-alb:
    target_group:
      targets:
        - instance_key: "app-server-01"  # References the EC2 instance above
          port: 8080
```

## 🌍 Multi-Environment Support

### Option 1: Separate YAML Files

```
multi-resource/
├── resources-dev.yaml
├── resources-staging.yaml
├── resources-prod.yaml
```

Use variable to select file:
```bash
terraform apply -var="resources_config_file=resources-prod.yaml"
```

### Option 2: Terraform Workspaces

```bash
terraform workspace select prod
terraform apply  # Uses prod-specific configuration
```

## 🔐 Secrets Management

Sensitive values (passwords, keys) should come from Harness secrets:

```yaml
# In Harness pipeline varFiles
rds_passwords = {
  "mysql-primary" = "<+secrets.getValue('mysql_password')>"
}
```

## 📊 Outputs

After deployment, access comprehensive outputs:

```bash
terraform output deployment_summary
terraform output ec2_instances
terraform output rds_instances
terraform output load_balancers
```

In Harness, use outputs in downstream steps:
```yaml
<+pipeline.stages.deploy.spec.execution.steps.terraform_apply.output.ec2_instances>
```

## 🎨 Adding New Resource Types

The framework is designed for easy extension. To add a new resource type (e.g., EKS):

### 1. Add to `resources.yaml`

```yaml
eks_clusters:
  main-cluster:
    enabled: true
    cluster_name: "app-eks-cluster"
    cluster_version: "1.28"
    # ... more config
```

### 2. Update `main.tf`

Uncomment and customize the EKS module block:

```terraform
module "eks_clusters" {
  for_each = local.merged_eks_configs
  source   = "../../eks"
  
  cluster_name = each.value.cluster_name
  # ... more config
}
```

### 3. Add outputs to `outputs.tf`

```terraform
output "eks_clusters" {
  value = {
    for k, v in module.eks_clusters : k => {
      name     = v.cluster_name
      endpoint = v.cluster_endpoint
    }
  }
}
```

That's it! See [EXTENDING.md](./EXTENDING.md) for detailed guide.

## 📚 Documentation

- **[USAGE.md](./USAGE.md)** - Detailed usage guide with examples
- **[EXTENDING.md](./EXTENDING.md)** - How to add new resource types
- **[HARNESS_INTEGRATION.md](./HARNESS_INTEGRATION.md)** - Harness pipeline setup
- **[EXAMPLES.md](./EXAMPLES.md)** - Common deployment scenarios

## 🤝 Contributing

To add support for a new AWS resource type:

1. Create the Terraform module in the parent directory
2. Add the resource structure to `resources.yaml` (with `enabled: false`)
3. Add the module block to `main.tf` (can be commented out initially)
4. Add outputs to `outputs.tf`
5. Update documentation

## ⚠️ Important Notes

- **State Management**: Always use remote state (S3) for production deployments
- **Secrets**: Never commit sensitive values to the YAML file
- **Module Compatibility**: Ensure your existing modules match the variable names used in `main.tf`
- **Resource Dependencies**: Terraform automatically handles dependencies between resources

## 🐛 Troubleshooting

### Issue: Module variable not found
**Solution**: Check that `main.tf` uses the correct variable names from your modules. Update the module call to match your module's interface.

### Issue: YAML parsing error
**Solution**: Validate YAML syntax. Use a YAML linter or `yamllint resources.yaml`.

### Issue: Resource not deploying
**Solution**: Check that `enabled: true` is set for the resource and the resource type is not commented out in `main.tf`.

## 📝 License

Internal use only - BeiGene Infrastructure Team

## 👥 Support

For questions or issues:
- Infrastructure Team Slack: #infra-terraform
- Email: infrastructure-team@beigenecorp.com
