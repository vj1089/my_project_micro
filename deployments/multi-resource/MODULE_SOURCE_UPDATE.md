# Module Source Variable Update Summary

## 🎯 What Changed

The framework now uses a **single variable** (`module_source_prefix`) to control all module sources, making it extremely easy to switch between local development and remote production modules.

## 📝 Changes Made

### 1. **variables.tf** - New Variable
```hcl
variable "module_source_prefix" {
  type        = string
  description = "Prefix for all module sources. Can be local path (../..) or remote (git::https://..., app.terraform.io/org/, etc.)"
  default     = "../.."
}
```

### 2. **main.tf** - Updated Module Sources
All module blocks now use:
```hcl
source = "${var.module_source_prefix}/ec2-instance"
source = "${var.module_source_prefix}/rds"
source = "${var.module_source_prefix}/elb"
source = "${var.module_source_prefix}/eks"
source = "${var.module_source_prefix}/ecs"
source = "${var.module_source_prefix}/efs"
source = "${var.module_source_prefix}/lambda"
source = "${var.module_source_prefix}/s3"
```

### 3. **Documentation Updates**
All documentation files updated with module source examples:
- ✅ `README.md` - Added module source configuration section
- ✅ `GETTING_STARTED.md` - Updated quick start with module source examples
- ✅ `HARNESS_INTEGRATION.md` - Added module_source_prefix to pipeline variables
- ✅ `EXAMPLES.md` - Added module source configuration section
- ✅ `EXTENDING.md` - Updated module creation guidance

## 🚀 Usage Examples

### Local Development (Default)
```bash
# Uses default: module_source_prefix = "../.."
terraform init
terraform plan
terraform apply
```

### Git Repository with Versioning
```bash
# Command line
terraform plan -var='module_source_prefix=git::https://github.com/your-org/terraform-modules.git//aws?ref=v1.2.3'

# terraform.tfvars file
cat > terraform.tfvars <<EOF
module_source_prefix = "git::https://github.com/your-org/terraform-modules.git//aws?ref=v1.2.3"
EOF
terraform init
terraform apply
```

### Terraform Registry
```bash
terraform plan -var='module_source_prefix=app.terraform.io/your-org'
```

### S3 Bucket
```bash
terraform plan -var='module_source_prefix=s3::https://s3.amazonaws.com/terraform-modules/aws'
```

### Harness Pipeline
```yaml
variables:
  - name: module_source_prefix
    type: String
    value: "git::https://github.com/your-org/terraform-modules.git//aws?ref=v1.0.0"
    description: "Module source for all AWS resources"

# In Terraform/OpenTofu Apply step
varFiles:
  - varFile:
      type: Inline
      spec:
        content: |
          module_source_prefix = "<+pipeline.variables.module_source_prefix>"
```

## 🎨 Benefits

1. **Single Point of Control**: Change ALL module sources with ONE variable
2. **Environment-Specific Sources**:
   - Dev: Use local modules (`../..`)
   - Staging: Use branch (`?ref=develop`)
   - Prod: Use tagged version (`?ref=v1.2.3`)
3. **Easy Testing**: Switch between local and remote modules without code changes
4. **Version Control**: Pin production to specific versions/commits
5. **Flexibility**: Supports Git, Terraform Registry, S3, HTTP, and local paths

## 📊 Module Resolution Examples

| `module_source_prefix` | EC2 Module Resolves To |
|------------------------|------------------------|
| `../..` | `../../ec2-instance` |
| `git::https://github.com/org/modules.git//aws` | `git::https://github.com/org/modules.git//aws/ec2-instance` |
| `git::https://github.com/org/modules.git//aws?ref=v1.0.0` | `git::https://github.com/org/modules.git//aws/ec2-instance?ref=v1.0.0` |
| `app.terraform.io/myorg` | `app.terraform.io/myorg/ec2-instance` |
| `s3::https://s3.amazonaws.com/modules/aws` | `s3::https://s3.amazonaws.com/modules/aws/ec2-instance` |

## ⚡ Migration from Previous Setup

If you were using the framework before this change:

**No action required!** The default value `../..` maintains backward compatibility with local module development.

**To use remote modules:**
```bash
# Just add the variable
terraform plan -var='module_source_prefix=git::https://...'
```

## 🔒 Best Practices

### Development
```hcl
module_source_prefix = "../.."  # Local modules for fast iteration
```

### Staging
```hcl
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=develop"  # Latest develop branch
```

### Production
```hcl
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=v1.2.3"  # Pinned version
```

### Critical Production
```hcl
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=abc123def"  # Specific commit SHA
```

## 📚 Related Documentation

- **Module Source Syntax**: [Terraform Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources)
- **Git Reference Syntax**: Use `?ref=` for branches, tags, or commits
- **Registry Syntax**: Follow `<HOSTNAME>/<NAMESPACE>/<NAME>/<PROVIDER>` pattern

## ✅ Verification

To verify your setup:

```bash
# Check variable is set correctly
terraform console
> var.module_source_prefix

# View resolved module sources in plan
terraform plan

# The plan output will show the full resolved module source paths
```

## 🆘 Troubleshooting

### Issue: Module not found
```
Error: Module not found
```
**Solution**: Verify the module exists at the resolved path. Check:
1. Prefix is correct
2. Module subdirectory name matches (e.g., `ec2-instance`, not `ec2`)
3. For Git: branch/tag/commit exists
4. For private repos: credentials are configured

### Issue: Need to re-initialize
```
Error: Module not installed
```
**Solution**: Run `terraform init` after changing `module_source_prefix`:
```bash
terraform init -upgrade
```

### Issue: Using wrong Git ref
**Solution**: Always specify `?ref=` for Git sources:
```hcl
# ✅ Good
module_source_prefix = "git::https://github.com/org/modules.git//aws?ref=v1.0.0"

# ❌ Bad (uses default branch)
module_source_prefix = "git::https://github.com/org/modules.git//aws"
```

## 🎉 Summary

You can now easily switch your entire infrastructure deployment between:
- **Local development** (fast iteration)
- **Remote Git repositories** (collaboration, versioning)
- **Terraform Registry** (public/private)
- **S3/HTTP sources** (enterprise artifact repositories)

All with a single variable change! 🚀
