# Quick Reference Guide

## 🚀 Common Commands

### Local Development
```bash
cd deployments/multi-resource
terraform init
terraform plan
terraform apply
```

### Using Remote Modules
```bash
# Via command line
terraform init -var="module_source_prefix=git::https://github.com/org/modules.git//aws?ref=v1.0.0"
terraform plan -var="module_source_prefix=git::https://github.com/org/modules.git//aws?ref=v1.0.0"
terraform apply -var="module_source_prefix=git::https://github.com/org/modules.git//aws?ref=v1.0.0"

# Via terraform.tfvars
echo 'module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=v1.0.0"' > terraform.tfvars
terraform init
terraform apply
```

### Using OpenTofu
```bash
tofu init
tofu plan -var="module_source_prefix=app.terraform.io/your-org"
tofu apply
```

## 🔧 Module Source Prefix Examples

| Environment | Prefix Value | Use Case |
|-------------|--------------|----------|
| **Development** | `../..` | Local modules, fast iteration |
| **Testing** | `git::https://github.com/org/modules.git//aws?ref=develop` | Latest development branch |
| **Staging** | `git::https://github.com/org/modules.git//aws?ref=v1.2.3-rc1` | Release candidate testing |
| **Production** | `git::https://github.com/org/modules.git//aws?ref=v1.2.3` | Stable, versioned release |
| **Critical Prod** | `git::https://github.com/org/modules.git//aws?ref=abc123` | Pinned to specific commit |
| **Registry** | `app.terraform.io/your-org` | Terraform Cloud/Enterprise |
| **S3** | `s3::https://s3.amazonaws.com/modules/aws` | Private enterprise modules |

## 📝 Quick Edits

### Add an EC2 Instance
```yaml
# In resources.yaml
ec2_instances:
  new-server:
    enabled: true
    instance_name: "new-server-01"
    ami_id: "ami-xxx"
    instance_type: "t3.medium"
    subnet_id: "subnet-xxx"
    key_name: "your-key"
    tags:
      Name: "new-server-01"
```

### Disable a Resource
```yaml
ec2_instances:
  temp-server:
    enabled: false  # Resource ignored, config preserved
```

### Add Tags to All Resources
```yaml
common:
  common_tags:
    department: "Engineering"
    cost_center: "CC-1234"
    environment: "production"
```

## 🔐 Secrets in Harness

```yaml
# In Harness Pipeline Variables
varFiles:
  - varFile:
      type: Inline
      spec:
        content: |
          module_source_prefix = "<+pipeline.variables.module_source_prefix>"
          rds_passwords = {
            db-name = "<+secrets.getValue('rds_password')>"
          }
          kms_key_arn = "<+secrets.getValue('kms_key_arn')>"
```

## 📊 Useful Outputs

```bash
# View all outputs
terraform output

# Specific output
terraform output deployment_summary
terraform output ec2_instances
terraform output rds_instances

# JSON format
terraform output -json deployment_summary
```

## 🐛 Troubleshooting

### Module not found after changing prefix
```bash
# Solution: Re-initialize
terraform init -upgrade
```

### YAML parsing error
```bash
# Solution: Validate YAML syntax
yamllint resources.yaml

# Or use online validator
https://www.yamllint.com/
```

### Resource not deploying
```yaml
# Check 1: enabled flag
enabled: true  # Must be true

# Check 2: Module block uncommented in main.tf
# For EKS, ECS, etc., uncomment the module block
```

### Wrong module version
```bash
# Solution: Specify ref parameter
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=v1.2.3"
#                                                                          ^^^^^^^^^^^
```

## 📚 File Overview

| File | Purpose |
|------|---------|
| `resources.yaml` | Define all infrastructure resources |
| `main.tf` | Orchestrates module deployment |
| `variables.tf` | Variable definitions |
| `outputs.tf` | Export resource details |
| `provider.tf` | AWS provider, backend config |
| `README.md` | Complete documentation |
| `GETTING_STARTED.md` | Quick start guide |
| `EXTENDING.md` | Add new resource types |
| `HARNESS_INTEGRATION.md` | Harness pipeline setup |
| `EXAMPLES.md` | Real-world scenarios |

## 🎯 Workflow Examples

### Development Workflow
```bash
# 1. Edit resources.yaml
vim resources.yaml

# 2. Plan
terraform plan

# 3. Apply
terraform apply

# 4. Check outputs
terraform output deployment_summary
```

### Production Deployment
```bash
# 1. Update version in terraform.tfvars
cat > terraform.tfvars <<EOF
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=v1.2.3"
EOF

# 2. Initialize with new modules
terraform init -upgrade

# 3. Plan and save
terraform plan -out=prod.tfplan

# 4. Review plan
terraform show prod.tfplan

# 5. Apply
terraform apply prod.tfplan
```

### Multi-Environment
```bash
# Development
terraform workspace select dev
terraform apply -var="module_source_prefix=../.."

# Staging  
terraform workspace select staging
terraform apply -var="module_source_prefix=git::https://...?ref=develop"

# Production
terraform workspace select prod
terraform apply -var="module_source_prefix=git::https://...?ref=v1.0.0"
```

## 🔄 Common Patterns

### Cross-Resource Reference
```yaml
# EC2 instance
ec2_instances:
  app-server:
    instance_name: "app-01"
    # ...

# ALB targeting EC2
load_balancers:
  app-alb:
    target_group:
      targets:
        - instance_key: "app-server"  # References above EC2
          port: 8080
```

### Tag Inheritance
```yaml
common:
  common_tags:
    department: "Eng"    # Applied to ALL resources

ec2_instances:
  server-01:
    tags:
      tier: "app"        # Merged with common_tags
# Result: department=Eng, tier=app
```

### Conditional Deployment
```yaml
ec2_instances:
  optional-server:
    enabled: false       # Skipped, but config kept

rds_instances:
  production-db:
    enabled: true        # Deployed
```

## 🌐 Remote Module Sources

### GitHub (Public)
```hcl
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=v1.0.0"
```

### GitHub (Private, SSH)
```hcl
module_source_prefix = "git::git@github.com:org/modules.git//aws?ref=v1.0.0"
```

### GitLab
```hcl
module_source_prefix = "git::https://gitlab.com/org/modules.git//aws?ref=v1.0.0"
```

### Terraform Registry (Public)
```hcl
module_source_prefix = "hashicorp"  # Public modules
```

### Terraform Cloud/Enterprise (Private)
```hcl
module_source_prefix = "app.terraform.io/your-org"
```

### S3
```hcl
module_source_prefix = "s3::https://s3.amazonaws.com/terraform-modules/aws"
```

### HTTP
```hcl
module_source_prefix = "https://artifactory.company.com/terraform/aws"
```

## 💡 Tips & Tricks

1. **Always use version tags in production**
   ```hcl
   module_source_prefix = "git::https://...?ref=v1.2.3"  # ✅ Good
   module_source_prefix = "git::https://..."              # ❌ Bad (unstable)
   ```

2. **Use semantic versioning**
   - `v1.0.0` - Major release
   - `v1.1.0` - Minor features
   - `v1.1.1` - Bug fixes

3. **Test before production**
   ```bash
   # Staging
   module_source_prefix = "git::https://...?ref=v2.0.0-rc1"
   
   # After testing, promote to prod
   module_source_prefix = "git::https://...?ref=v2.0.0"
   ```

4. **Keep resources.yaml in version control**
   ```bash
   git add resources.yaml
   git commit -m "Add new production database"
   ```

5. **Use workspaces for environments**
   ```bash
   terraform workspace new staging
   terraform workspace new production
   ```

6. **Document your changes**
   ```yaml
   # resources.yaml
   ec2_instances:
     # Added 2025-11-13 for new microservice deployment
     api-server:
       enabled: true
   ```

## 📞 Support

- **Documentation**: See README.md, EXTENDING.md, EXAMPLES.md
- **Issues**: Check YAML syntax, module availability, variable names
- **Harness**: See HARNESS_INTEGRATION.md for pipeline setup
