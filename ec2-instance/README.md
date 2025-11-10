# EC2 Instance Terraform Module

This Terraform module provisions a single EC2 instance with secure defaults, flexible KMS encryption options, AMI selection capabilities, and comprehensive tagging support. The module is designed for enterprise environments with security and compliance requirements.

## Features

- **Security by Default**: EBS encryption enabled, IMDSv2 required, secure security group management
- **Flexible KMS Selection**: Explicit ARN specification or alias-based auto-discovery
- **AMI Management**: Support for both explicit AMI IDs and pattern-based AMI lookup
- **Security Group Integration**: CSV-format security rules supporting CIDR blocks, Security Group IDs, and Prefix List IDs
- **Comprehensive Tagging**: Built-in support for enterprise tagging standards including RPO/RTO
- **User Data Support**: Automated OS detection and user data script execution
- **Multi-OS Support**: Linux and Windows instance support with appropriate configurations

## Usage

### Basic Example

```hcl
module "web_server" {
  source = "./ec2-instance"

  # Required variables
  region            = "us-west-2"
  ami_id            = "ami-0123456789abcdef0"
  instance_name     = "web-server-01"
  app_instance_type = "t3.medium"
  key_name          = "my-keypair"
  vpc_id            = "vpc-abc123def456"
  private_subnets   = ["subnet-11111111"]

  # Security group rules
  sg_rules_ec2 = [
    "22,tcp,10.0.0.0/8,SSH from internal network",
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet"
  ]

  # KMS encryption
  kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Required tagging
  application = "web-app"
  environment = "production"
  it_owner    = "DevOps Team"
  BPO         = "Application Owner"
  compliance  = "GxP"
  RPO         = 4
  RTO         = 2
  department  = "GTS - Infrastructure & Operations"
}
```

### Advanced Example with AMI Lookup and Alias-Based KMS

```hcl
module "database_server" {
  source = "./ec2-instance"

  # Basic configuration
  region            = var.region
  instance_name     = "database-server-${var.environment}"
  app_instance_type = "r5.xlarge"
  key_name          = var.key_name
  vpc_id            = var.vpc_id
  private_subnets   = var.private_subnets

  # AMI lookup instead of hardcoded ID
  ami_lookup_enabled = true
  ami_name_filter    = "amzn2-ami-hvm-*-x86_64-gp2"
  ami_owners         = ["amazon"]

  # KMS alias-based auto-discovery
  enable_kms_alias_lookup = true
  kms_key_alias_name_base = "alias/ebs-key"

  # Security group rules with mixed source types
  sg_rules_ec2 = [
    "3306,tcp,sg-0123456789abcdef0,MySQL from web servers",
    "22,tcp,10.0.100.0/24,SSH from admin subnet",
    "443,tcp,pl-0123456789abcdef0,HTTPS via prefix list"
  ]

  # Storage configuration
  root_vol_size = "100"
  ebs_vol_size  = "500"

  # Tagging
  application = "database"
  environment = var.environment
  it_owner    = "Database Team"
  BPO         = "Data Management"
  compliance  = "GxP"
  RPO         = 1
  RTO         = 1
  department  = "GTS - Infrastructure & Operations"
}
```

## Security Group Rules Format

The module accepts security group rules in CSV format through the `sg_rules_ec2` variable:

### Rule Format
`"<port-or-range>,<protocol>,<source>,<description>"`

### Source Types

The module automatically detects source types:

- **CIDR blocks**: Any source not starting with `sg-` or `pl-`
- **Security Group IDs**: Sources starting with `sg-`
- **Prefix List IDs**: Sources starting with `pl-`

### Examples

```hcl
sg_rules_ec2 = [
  # Single port with CIDR
  "22,tcp,10.8.126.221/32,SSH from admin workstation",
  
  # Port range with CIDR
  "8080-8090,tcp,10.0.0.0/16,Application ports from VPC",
  
  # Security Group reference
  "3306,tcp,sg-0123456789abcdef0,MySQL from app security group",
  
  # Prefix List reference
  "53,udp,pl-0123456789abcdef0,DNS via Route53 Resolver",
  
  # Multiple examples
  "80,tcp,0.0.0.0/0,HTTP from internet",
  "443,tcp,0.0.0.0/0,HTTPS from internet",
  "1024-2048,tcp,10.8.0.0/24,Ephemeral ports from internal"
]
```

## KMS Encryption Options

The module supports three KMS configuration methods (in order of precedence):

### 1. Explicit KMS ARN (Highest Priority)
```hcl
kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### 2. Alias-Based Auto-Discovery
```hcl
enable_kms_alias_lookup = true
kms_key_alias_name_base = "alias/ebs-key"  # Resolves to alias/ebs-key-<region>
```

### 3. AWS-Managed Default (Fallback)
If neither of the above is specified, AWS-managed EBS encryption is used.

## AMI Selection Options

### Option 1: Explicit AMI ID (Recommended for Production)
```hcl
ami_id = "ami-0123456789abcdef0"
```

### Option 2: Pattern-Based AMI Lookup
```hcl
ami_lookup_enabled = true
ami_name_filter    = "amzn2-ami-hvm-*-x86_64-gp2"
ami_owners         = ["amazon"]
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region where resources will be created | `string` | n/a | yes |
| ami_id | AMI ID for the EC2 instance | `string` | `""` | conditional* |
| instance_name | Name tag for the EC2 instance | `string` | n/a | yes |
| app_instance_type | EC2 instance type | `string` | n/a | yes |
| key_name | SSH/RDP key pair name | `string` | n/a | yes |
| vpc_id | VPC ID where the instance will be created | `string` | n/a | yes |
| private_subnets | List of private subnet IDs (first one used) | `list(string)` | n/a | yes |
| sg_rules_ec2 | List of security group rules in CSV format | `list(string)` | `[]` | no |
| ami_lookup_enabled | Enable AMI lookup by name pattern | `bool` | `false` | no |
| ami_name_filter | AMI name pattern for lookup | `string` | `""` | conditional** |
| ami_owners | List of AMI owners for lookup | `list(string)` | `["amazon"]` | no |
| os_type | Operating system type (linux/windows) | `string` | `"linux"` | no |
| root_vol_size | Root volume size in GB | `string` | `"30"` | no |
| ebs_vol_size | Additional EBS volume size in GB | `string` | `"10"` | no |
| kms_key_arn | Explicit KMS key ARN for encryption | `string` | `""` | no |
| enable_kms_alias_lookup | Enable KMS alias-based lookup | `bool` | `false` | no |
| kms_key_alias_name_base | Base name for KMS alias lookup | `string` | `"alias/ebs-key"` | no |
| instance_role | IAM instance profile role name | `string` | `"AmazonSSMRoleForInstancesQuickSetup"` | no |
| application | Application name for tagging | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| it_owner | IT Owner for tagging | `string` | n/a | yes |
| BPO | Business Process Owner | `string` | n/a | yes |
| compliance | Compliance requirement (GxP, Non-GxP) | `string` | n/a | yes |
| RPO | Recovery Point Objective in hours | `number` | n/a | yes |
| RTO | Recovery Time Objective in hours | `number` | n/a | yes |
| department | Department responsible for the resource | `string` | n/a | yes |

\* Required if `ami_lookup_enabled = false`  
\** Required if `ami_lookup_enabled = true`

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| instance_public_ip | Public IP address of the instance |
| instance_private_ip | Private IP address of the instance |
| instance_public_dns | Public DNS name of the instance |
| instance_private_dns | Private DNS name of the instance |
| security_group_id | ID of the created security group |
| security_group_arn | ARN of the created security group |
| key_pair_name | Name of the key pair used |
| subnet_id | ID of the subnet where instance is launched |

## Common Use Cases

### 1. Web Server

```hcl
module "web_server" {
  source = "./ec2-instance"
  
  region            = "us-west-2"
  instance_name     = "web-server-${var.environment}"
  app_instance_type = "t3.medium"
  key_name          = var.key_name
  vpc_id            = var.vpc_id
  private_subnets   = var.web_subnets
  
  ami_lookup_enabled = true
  ami_name_filter    = "amzn2-ami-hvm-*-x86_64-gp2"
  
  sg_rules_ec2 = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet",
    "22,tcp,${var.admin_cidr},SSH from admin network"
  ]
  
  # Tagging
  application = "web-app"
  environment = var.environment
  it_owner    = "Web Team"
}
```

### 2. Database Server

```hcl
module "database_server" {
  source = "./ec2-instance"
  
  region            = var.region
  instance_name     = "database-server-${var.environment}"
  app_instance_type = "r5.xlarge"
  key_name          = var.key_name
  vpc_id            = var.vpc_id
  private_subnets   = var.database_subnets
  
  root_vol_size = "100"
  ebs_vol_size  = "500"
  
  sg_rules_ec2 = [
    "3306,tcp,${module.web_server.security_group_id},MySQL from web servers",
    "22,tcp,${var.admin_cidr},SSH from admin network"
  ]
  
  # Tagging
  application = "database"
  environment = var.environment
  compliance  = "GxP"
  RPO         = 1
  RTO         = 1
}
```

### 3. Windows Server

```hcl
module "windows_server" {
  source = "./ec2-instance"
  
  region            = var.region
  instance_name     = "windows-server-${var.environment}"
  app_instance_type = "t3.large"
  os_type           = "windows"
  key_name          = var.key_name
  vpc_id            = var.vpc_id
  private_subnets   = var.private_subnets
  
  sg_rules_ec2 = [
    "3389,tcp,${var.admin_cidr},RDP from admin network",
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet"
  ]
  
  # Tagging
  application = "windows-app"
  environment = var.environment
  it_owner    = "Windows Team"
}
```

## File Structure

```
ec2-instance/
├── main.tf                     # EC2 instance and related resources
├── security_group.tf           # Security group configuration
├── datasource.tf              # Data sources for AMI, subnets, etc.
├── locals.tf                  # Local values and computations
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── provider.tf                # Provider configuration
├── versions.tf                # Version constraints
├── terraform.tfvars          # Example configuration
├── terraform.tfvars.example  # Detailed example
├── README.md                 # This file
└── userdata/                 # User data scripts
    ├── init_linux            # Linux initialization script
    └── init_win              # Windows initialization script
```

## Best Practices

1. **Security First**: Always use customer-managed KMS keys for production workloads
2. **Tagging Standards**: Ensure all required tags are provided for compliance and cost tracking
3. **AMI Management**: Use explicit AMI IDs for production to ensure consistency
4. **Network Security**: Follow least privilege principle for security group rules
5. **Instance Sizing**: Right-size instances based on actual workload requirements
6. **Backup Strategy**: Set appropriate RPO/RTO values based on business requirements

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 4.0 |
| random | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |
| random | ~> 3.1 |

## Migration Guide

### From Existing EC2 Configurations

This module is designed to be compatible with existing EC2 instance configurations. Key migration considerations:

1. **Security Group Rules**: Convert existing security group rules to CSV format
2. **Tagging**: Ensure all required tag variables are provided
3. **KMS Keys**: Consider migrating to alias-based KMS management for consistency

### Example Migration

**Before:**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t3.medium"
  # ... other configurations
}
```

**After:**
```hcl
module "web_server" {
  source = "./ec2-instance"
  
  ami_id            = "ami-12345"
  instance_name     = "web-server"
  app_instance_type = "t3.medium"
  # ... other required variables
}
```

## Troubleshooting

### Common Issues

1. **KMS Alias Not Found**
   - Verify alias exists: `aws kms list-aliases --region <region>`
   - Check alias naming convention matches `${kms_key_alias_name_base}-${region}`

2. **AMI Lookup Returns No Results**
   - Verify `ami_name_filter` pattern is correct
   - Check `ami_owners` list includes the correct owner IDs
   - Ensure AMIs exist in the target region

3. **Security Group Rule Parsing Errors**
   - Verify CSV format: `"port,protocol,source,description"`
   - Avoid commas in descriptions
   - Check source format (CIDR, sg-*, or pl-*)

4. **Instance Launch Failures**
   - Verify subnet has available IP addresses
   - Check instance type availability in the region/AZ
   - Ensure IAM permissions for instance profile

### Debug Commands

```bash
# Check KMS aliases
aws kms list-aliases --region us-west-2

# Verify AMI availability
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*"

# Check subnet capacity
aws ec2 describe-subnets --subnet-ids subnet-12345

# Validate security group rules
terraform plan -target=aws_security_group.sg
```

## Support

For questions, issues, or contributions:

1. **Internal Support**: Contact the Infrastructure Team
2. **Documentation**: Check the `terraform.tfvars.example` for detailed configuration examples
3. **Testing**: Use the provided examples in a development environment before production deployment

## License

This module is maintained by the Infrastructure Team. For questions or issues, please contact the DevOps team.