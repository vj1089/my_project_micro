# YAML Generator User Guide

## 🎯 Overview

The **YAML Generator** is a web-based tool that allows anyone to create AWS infrastructure configuration files **without writing any code or knowing YAML syntax**.

## ✨ Why Use the Generator?

### For Non-Technical Users:
- ✅ **No coding required** - just fill in forms and click buttons
- ✅ **Visual interface** - see what you're creating in real-time
- ✅ **Guided inputs** - dropdown menus and helpful hints
- ✅ **Instant preview** - see the generated YAML immediately
- ✅ **One-click download** - get your `resources.yaml` file ready to use

### For Technical Users:
- ⚡ **Faster** - no need to remember YAML syntax or structure
- 🎯 **Accurate** - prevents syntax errors and formatting issues
- 📋 **Template** - quickly create base configuration, then customize
- 🔄 **Reusable** - save time on repetitive configurations

## 🚀 Getting Started

### Step 1: Open the Generator

```bash
# Windows
start yaml-generator.html

# Mac
open yaml-generator.html

# Linux
xdg-open yaml-generator.html

# Or just drag and drop the file into your web browser
```

### Step 2: Fill in the Form

The interface is divided into sections:

#### 1. **Common Configuration** (Required)
- **AWS Region**: Select your AWS region from dropdown
- **VPC ID**: Enter your VPC identifier (looks like `vpc-0123456789abcdef0`)
- **Environment**: Choose dev, staging, prod, or qa
- **Common Tags**: Add tags that apply to ALL resources

#### 2. **EC2 Instances** (Optional)
Click "+ Add EC2 Instance" to add servers:
- **Instance Key**: Unique name (e.g., `web-server-01`)
- **Instance Name**: Display name for the server
- **AMI ID**: Amazon Machine Image ID (e.g., `ami-0123456789abcdef0`)
- **Instance Type**: Server size (t3.micro, t3.medium, etc.)
- **Subnet ID**: Which subnet to deploy in
- **Key Pair**: SSH key for Linux or RDP for Windows
- **OS Type**: Linux or Windows

#### 3. **RDS Databases** (Optional)
Click "+ Add RDS Database" to add databases:
- **Database Key**: Unique name (e.g., `app-db`)
- **DB Identifier**: AWS identifier for the database
- **Engine**: MySQL, PostgreSQL, SQL Server, or MariaDB
- **Engine Version**: Database version (e.g., 8.0 for MySQL)
- **Instance Class**: Database size (db.t3.micro, db.m5.large, etc.)
- **Storage**: Storage size in GB
- **Username**: Master database username
- **Subnet IDs**: Comma-separated subnet IDs
- **Multi-AZ**: Check for high availability

#### 4. **Load Balancers** (Optional)
Click "+ Add Load Balancer" to add load balancers:
- **Load Balancer Key**: Unique name (e.g., `web-alb`)
- **Name**: AWS name for the load balancer
- **Internal**: Check if this is for internal traffic only
- **Subnet IDs**: Comma-separated subnet IDs
- **Target Group**: Configuration for routing traffic
- **Health Check Path**: URL path to check (e.g., `/health`)

### Step 3: Generate YAML

As you fill in the form, the YAML is **automatically generated** in the right panel.

You can also click **"📝 Generate YAML"** button to refresh the output.

### Step 4: Download or Copy

- **💾 Download File**: Downloads `resources.yaml` to your computer
- **📋 Copy to Clipboard**: Copies YAML text to clipboard

## 📋 Example Walkthrough

Let's create a simple web application infrastructure:

### Example: Web Server + Database + Load Balancer

1. **Common Configuration**
   - Region: `us-east-1`
   - VPC ID: `vpc-abc123`
   - Environment: `production`
   - Add tag: `department` = `Engineering`

2. **Add EC2 Instance**
   - Click "+ Add EC2 Instance"
   - Instance Key: `web-server`
   - Instance Name: `production-web-01`
   - AMI ID: `ami-0c55b159cbfafe1f0`
   - Instance Type: `t3.medium`
   - Subnet ID: `subnet-web-1`
   - Key Pair: `my-ssh-key`
   - OS Type: `Linux`

3. **Add RDS Database**
   - Click "+ Add RDS Database"
   - Database Key: `app-db`
   - DB Identifier: `production-mysql`
   - Engine: `MySQL`
   - Engine Version: `8.0`
   - Instance Class: `db.t3.medium`
   - Storage: `100`
   - Username: `admin`
   - Subnet IDs: `subnet-db-1, subnet-db-2`
   - Check "Multi-AZ"

4. **Add Load Balancer**
   - Click "+ Add Load Balancer"
   - Load Balancer Key: `web-alb`
   - Name: `production-web-alb`
   - Subnet IDs: `subnet-public-1, subnet-public-2`
   - Target Group Name: `web-targets`
   - Target Port: `80`
   - Health Check Path: `/health`

5. **Download**
   - Click "💾 Download File"
   - File saved as `resources.yaml`

## 🎨 Features Guide

### Enabling/Disabling Resources

Each resource has an **"Enabled"** checkbox:
- ✅ **Checked**: Resource will be deployed
- ☐ **Unchecked**: Resource configuration is saved but not deployed

This is useful for:
- Temporarily disabling resources without deleting configuration
- Testing infrastructure with fewer resources
- Staged rollouts

### Adding Multiple Resources

You can add as many resources as needed:
- Multiple EC2 instances (web servers, app servers, databases)
- Multiple RDS databases (primary, replica, different engines)
- Multiple load balancers (public, internal, different applications)

Just keep clicking the "+ Add" buttons!

### Removing Resources

Each resource has a **"Remove"** button in the top-right corner.
- Removes that resource from the configuration
- Does NOT affect other resources

### Common Tags

Tags added in "Common Configuration" are automatically applied to ALL resources.

Example:
- Common tag: `department` = `Engineering`
- EC2 tag: `tier` = `web`
- **Result**: EC2 gets both tags: `department=Engineering` AND `tier=web`

### Real-Time Preview

The right panel shows the generated YAML in real-time:
- Updates as you type
- Shows exactly what will be in `resources.yaml`
- Syntax-highlighted for readability

## 💡 Tips & Best Practices

### 1. Naming Conventions

Use descriptive, consistent names:

✅ **Good**:
```
Instance Key: web-server-01
Database Key: mysql-primary
ALB Key: public-web-alb
```

❌ **Bad**:
```
Instance Key: server1
Database Key: db
ALB Key: alb
```

### 2. Resource Keys

Resource keys must be:
- Unique within each resource type
- Alphanumeric with hyphens (no spaces)
- Descriptive of the resource purpose

### 3. Fill Required Fields First

Fields marked with `*` are required:
- Region, VPC ID, Environment (Common)
- Instance Name, AMI, Type, Subnet (EC2)
- DB Identifier, Engine, Class, Storage (RDS)

### 4. Save Your Work

The generator runs entirely in your browser:
- **Download frequently** to save your configuration
- Browser refresh **will lose** all form data
- No auto-save feature (intentional for security)

### 5. Validate Before Deploy

After downloading `resources.yaml`:
1. Review the file in a text editor
2. Ensure all IDs (VPC, subnets, AMIs) are correct
3. Verify environment-specific settings
4. Test with `terraform plan` before `terraform apply`

### 6. Use Staging Environment First

Create configuration for staging before production:
1. Generate YAML for staging environment
2. Deploy and test
3. Copy configuration for production
4. Update environment-specific values
5. Deploy to production

## 🔧 Advanced Usage

### Template Generation

Use the generator to create a **template** configuration:

1. Fill in the form with placeholder values
2. Download YAML
3. Use text editor to replace placeholders with actual values
4. Commit template to version control

### Bulk Configuration

For many similar resources:

1. Create one resource in the generator
2. Download YAML
3. Copy and paste the resource block in a text editor
4. Modify values for each copy
5. Use the complete YAML file

### Version Control Integration

1. Generate `resources.yaml` using the tool
2. Save to your Git repository
3. Create branches for different environments
4. Use in Harness pipeline

```bash
git add resources.yaml
git commit -m "Add production infrastructure configuration"
git push origin main
```

## 🐛 Troubleshooting

### Issue: Download Button Doesn't Work

**Solutions**:
- Check browser's download settings
- Try "Copy to Clipboard" instead
- Try a different browser (Chrome, Firefox, Edge)

### Issue: YAML Looks Wrong

**Solutions**:
- Click "📝 Generate YAML" to refresh
- Check all required fields are filled
- Remove and re-add the problematic resource

### Issue: Can't See Preview Panel

**Solutions**:
- Maximize browser window (two-panel layout requires space)
- Scroll down on mobile devices (panels stack vertically)
- Use a larger screen or laptop

### Issue: Lost All Form Data

**Solutions**:
- Browser refresh clears all data (by design for security)
- Download frequently to save progress
- Consider keeping notes of values in a separate document

## 📊 Comparison with Manual YAML Editing

| Feature | YAML Generator | Manual Editing |
|---------|----------------|----------------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ Easy | ⭐⭐ Requires YAML knowledge |
| **Speed** | ⭐⭐⭐⭐⭐ Very fast | ⭐⭐⭐ Slower |
| **Error Prevention** | ⭐⭐⭐⭐⭐ No syntax errors | ⭐⭐ Easy to make mistakes |
| **Flexibility** | ⭐⭐⭐ Good for common cases | ⭐⭐⭐⭐⭐ Unlimited |
| **Learning Curve** | ⭐⭐⭐⭐⭐ None | ⭐⭐ Need to learn YAML |
| **Validation** | ⭐⭐⭐⭐ Form validation | ⭐⭐⭐ Need external tools |

**Recommendation**: 
- Use **Generator** for initial creation and simple configurations
- Use **Manual Editing** for complex customizations and advanced features

## 🎓 Next Steps

After generating your `resources.yaml`:

1. **Review the file** - Open in text editor to verify
2. **Place in correct directory** - Move to `deployments/multi-resource/`
3. **Configure secrets** - Set up RDS passwords, KMS keys in Harness
4. **Test locally** - Run `terraform plan` to validate
5. **Deploy** - Use Terraform/OpenTofu or Harness pipeline

See documentation:
- **README.md** - Framework overview
- **QUICK_REFERENCE.md** - Common commands
- **HARNESS_INTEGRATION.md** - Pipeline setup
- **EXAMPLES.md** - Real-world scenarios

## 🆘 Support

Need help?
- Check **EXAMPLES.md** for sample configurations
- See **QUICK_REFERENCE.md** for common patterns
- Review **EXTENDING.md** to add new resource types

## 🔒 Security Note

The YAML Generator:
- ✅ Runs entirely in your browser (no server)
- ✅ No data is sent to any server
- ✅ No data is stored (refresh clears everything)
- ✅ Safe for sensitive information (VPC IDs, subnet IDs, etc.)

However:
- ⚠️ Don't include passwords or secrets in the form
- ⚠️ Passwords should be configured separately in Harness Secret Manager
- ⚠️ The generator is for infrastructure configuration only

## 📝 Summary

The YAML Generator makes infrastructure configuration accessible to everyone:

- **Non-technical users**: Create infrastructure without learning YAML
- **Technical users**: Save time and prevent syntax errors
- **Teams**: Standardize configurations across projects
- **Rapid prototyping**: Quickly test different infrastructure layouts

**Start using it today**: Just open `yaml-generator.html` in your browser! 🚀
