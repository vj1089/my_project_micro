# Module Source Configuration - Important Note

## ⚠️ Terraform Limitation

**Terraform does not support variables in module `source` paths.** This is a core Terraform restriction, not a limitation of this framework.

```hcl
# ❌ This does NOT work in Terraform
module "example" {
  source = "${var.module_source_prefix}/ec2-instance"  # Error!
}

# ✅ This DOES work
module "example" {
  source = "../../ec2-instance"  # Static path required
}
```

## 🔧 How to Use Different Module Sources

### Option 1: Direct Path Editing (Simplest)

Edit `main.tf` and change the `source` paths directly:

**For Local Development:**
```hcl
module "ec2_instances" {
  source = "../../ec2-instance"
  # ...
}
```

**For Git-Based Modules:**
```hcl
module "ec2_instances" {
  source = "git::https://github.com/your-org/terraform-modules.git//aws/ec2-instance?ref=v1.0.0"
  # ...
}
```

**For Terraform Registry:**
```hcl
module "ec2_instances" {
  source = "app.terraform.io/your-org/ec2-instance/aws"
  # ...
}
```

### Option 2: Environment-Specific Directories (Recommended for Production)

Create separate deployment directories for each environment:

```
deployments/
├── dev/
│   ├── main.tf          # Uses local modules: ../../ec2-instance
│   ├── resources.yaml   # Dev configuration
│   └── terraform.tfvars
│
├── staging/
│   ├── main.tf          # Uses Git develop branch
│   ├── resources.yaml   # Staging configuration
│   └── terraform.tfvars
│
└── prod/
    ├── main.tf          # Uses Git versioned modules: ?ref=v1.0.0
    ├── resources.yaml   # Production configuration
    └── terraform.tfvars
```

**Example `dev/main.tf`:**
```hcl
module "ec2_instances" {
  source = "../../ec2-instance"  # Local modules for fast development
  # ...
}
```

**Example `prod/main.tf`:**
```hcl
module "ec2_instances" {
  source = "git::https://github.com/org/modules.git//aws/ec2-instance?ref=v1.2.3"
  # ...
}
```

### Option 3: Symlinks (Advanced)

Use symbolic links to switch between module sources:

```bash
# Development: point to local modules
ln -s ../../ec2-instance modules/ec2-instance
ln -s ../../rds modules/rds
ln -s ../../elb modules/elb

# In main.tf
module "ec2_instances" {
  source = "./modules/ec2-instance"
}

# Production: replace symlinks with versioned modules
rm modules/ec2-instance
git clone https://github.com/org/modules.git modules/ec2-instance -b v1.0.0
```

### Option 4: Terraform Workspaces with Separate Configs

```
multi-resource/
├── main-dev.tf      # Uses local modules
├── main-prod.tf     # Uses remote modules
├── resources.yaml
└── switch.sh        # Script to switch configs
```

**switch.sh:**
```bash
#!/bin/bash
ENV=$1

if [ "$ENV" = "dev" ]; then
  cp main-dev.tf main.tf
elif [ "$ENV" = "prod" ]; then
  cp main-prod.tf main.tf
fi

terraform init -reconfigure
```

## 📊 Comparison of Approaches

| Approach | Ease | Flexibility | Best For |
|----------|------|-------------|----------|
| **Direct Editing** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Simple setups, single environment |
| **Separate Directories** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **Production use (Recommended)** |
| **Symlinks** | ⭐⭐ | ⭐⭐⭐⭐ | Advanced users, Linux/Mac only |
| **Config Switching** | ⭐⭐⭐ | ⭐⭐⭐⭐ | CI/CD automation |

## 🎯 Recommended Approach

### For Learning/Development
Use **direct editing** with local modules:
```hcl
source = "../../ec2-instance"
```

### For Production
Use **separate directories** with versioned remote modules:

```
deployments/
├── dev/main.tf       → source = "../../ec2-instance"
├── staging/main.tf   → source = "git::...?ref=develop"
└── prod/main.tf      → source = "git::...?ref=v1.0.0"
```

## 🔄 Migration Guide

If you need to switch module sources:

### From Local to Remote:

1. **Backup current state:**
   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Edit main.tf** - change source paths:
   ```hcl
   # Before
   source = "../../ec2-instance"
   
   # After
   source = "git::https://github.com/org/modules.git//aws/ec2-instance?ref=v1.0.0"
   ```

3. **Reinitialize:**
   ```bash
   terraform init -upgrade
   ```

4. **Verify (should show no changes):**
   ```bash
   terraform plan
   ```

### From Remote to Local:

```bash
# 1. Edit main.tf (change source paths)
# 2. Reinitialize
terraform init -upgrade

# 3. Plan should show no changes if modules are compatible
terraform plan
```

## 💡 Tips

1. **Version Control**: Keep `main.tf` in version control with your preferred source
2. **Comments**: Add comments in `main.tf` showing alternative source paths
3. **Consistency**: Use the same module source pattern for all modules
4. **Testing**: Always run `terraform plan` after changing sources

## Example: Commented Alternatives in main.tf

```hcl
module "ec2_instances" {
  # Local development
  source = "../../ec2-instance"
  
  # Staging (Git develop branch)
  # source = "git::https://github.com/org/modules.git//aws/ec2-instance?ref=develop"
  
  # Production (Git versioned)
  # source = "git::https://github.com/org/modules.git//aws/ec2-instance?ref=v1.2.3"
  
  # Terraform Cloud/Enterprise
  # source = "app.terraform.io/your-org/ec2-instance/aws"
  
  for_each = local.merged_ec2_configs
  # ... rest of module config
}
```

This way, you can easily comment/uncomment the appropriate source!

## 🆘 Why This Limitation Exists

Terraform requires module sources to be known at **parse time** (before any variables are evaluated). This allows Terraform to:
- Download and cache modules before execution
- Validate module structure
- Build the dependency graph

This is why variables, which are only known at **runtime**, cannot be used in module sources.

## Summary

While we can't use a variable for module sources, the recommended pattern is:
1. **Development**: Use local paths in `main.tf`
2. **Production**: Create separate deployment directories with different `main.tf` files
3. **Version Control**: Keep module source paths in Git for traceability

This provides the flexibility you need while working within Terraform's constraints! 🚀
