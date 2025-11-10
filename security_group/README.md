# Security Group Terraform Module

This Terraform module creates AWS Security Groups with flexible ingress and egress rules. It supports both CSV-format rules (compatible with existing modules) and object-based rules for more complex configurations.

## Features

- **Flexible Rule Definition**: Supports both CSV-format rules and object-based rules
- **Multiple Source Types**: CIDR blocks, Security Group IDs, and Prefix List IDs
- **Port Ranges**: Single ports or port ranges (e.g., "8080-8090")
- **Automatic Tagging**: Consistent tagging following organization standards
- **Default Egress**: Optional default egress rule allowing all outbound traffic
- **Name Flexibility**: Supports both explicit names and name prefixes with random suffixes

## Usage

### Basic Example

```hcl
module "web_security_group" {
  source = "./security_group"

  region      = "us-west-2"
  name        = "web-server-sg-dev"
  description = "Security group for web servers"
  vpc_id      = "vpc-abc123def456"

  ingress_rules_list = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet",
    "22,tcp,10.0.0.0/8,SSH from internal network"
  ]

  # Tagging
  application = "web-app"
  environment = "dev"
  it_owner    = "DevOps Team"
}
```

### Advanced Example with Object-Based Rules

```hcl
module "database_security_group" {
  source = "./security_group"

  region      = var.region
  name_prefix = "database-sg-"
  description = "Security group for database servers"
  vpc_id      = var.vpc_id

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
  environment = "prod"
  compliance  = "GxP"
  it_owner    = "Database Team"
  BPO         = "Data Management"
  department  = "IT Infrastructure"

  additional_tags = {
    Backup      = "daily"
    Criticality = "high"
  }
}
```

## Rule Formats

### CSV-Format Rules (ingress_rules_list / egress_rules_list)

Format: `"port-or-range,protocol,source,description"`

**Examples:**
- Single port: `"22,tcp,10.0.0.0/8,SSH access"`
- Port range: `"8080-8090,tcp,192.168.1.0/24,App ports"`
- Security Group: `"3306,tcp,sg-0123456789abcdef0,MySQL from app SG"`
- Prefix List: `"443,tcp,pl-0123456789abcdef0,HTTPS via prefix list"`

### Object-Based Rules (ingress_rules / egress_rules)

```hcl
{
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]           # Optional
  ipv6_cidr_blocks        = ["::/0"]                 # Optional
  source_security_group_id = "sg-123456"            # Optional
  prefix_list_ids         = ["pl-123456"]           # Optional
  self                    = true                     # Optional
  description             = "HTTP access"           # Optional
}
```

## Source Types

The module automatically detects source types in CSV format:

- **CIDR blocks**: Any source not starting with `sg-` or `pl-`
  - Examples: `10.0.0.0/8`, `192.168.1.100/32`, `0.0.0.0/0`
- **Security Group IDs**: Sources starting with `sg-`
  - Examples: `sg-0123456789abcdef0`
- **Prefix List IDs**: Sources starting with `pl-`
  - Examples: `pl-0123456789abcdef0`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region where the security group will be created | `string` | n/a | yes |
| vpc_id | VPC ID where the security group will be created | `string` | n/a | yes |
| name | Name of the security group | `string` | `""` | no |
| name_prefix | Name prefix for the security group (random suffix added) | `string` | `""` | no |
| description | Description for the security group | `string` | `"Terraform managed security group"` | no |
| create_default_egress | Whether to create default egress rule allowing all outbound traffic | `bool` | `true` | no |
| ingress_rules_list | List of ingress rules in CSV format | `list(string)` | `[]` | no |
| egress_rules_list | List of egress rules in CSV format | `list(string)` | `[]` | no |
| ingress_rules | List of ingress rules as objects | `list(object)` | `[]` | no |
| egress_rules | List of egress rules as objects | `list(object)` | `[]` | no |
| application | Application name for tagging | `string` | `""` | no |
| environment | Environment (e.g., dev, prod, staging) | `string` | `""` | no |
| compliance | Compliance requirement | `string` | `""` | no |
| it_owner | IT Owner for tagging | `string` | `""` | no |
| BPO | Business Process Owner | `string` | `""` | no |
| department | Department responsible for the resource | `string` | `""` | no |
| additional_tags | Additional tags to apply to the security group | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | ID of the security group |
| security_group_arn | ARN of the security group |
| security_group_name | Name of the security group |
| security_group_description | Description of the security group |
| security_group_vpc_id | VPC ID of the security group |
| security_group_owner_id | Owner ID of the security group |
| security_group_tags | Tags applied to the security group |

## Common Use Cases

### 1. Web Server Security Group

```hcl
module "web_sg" {
  source = "./security_group"
  
  region = var.region
  name   = "web-server-sg-${var.environment}"
  vpc_id = var.vpc_id
  
  ingress_rules_list = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet",
    "22,tcp,${var.admin_cidr},SSH from admin network"
  ]
}
```

### 2. Database Security Group

```hcl
module "db_sg" {
  source = "./security_group"
  
  region                = var.region
  name                  = "database-sg-${var.environment}"
  vpc_id                = var.vpc_id
  create_default_egress = false
  
  ingress_rules_list = [
    "3306,tcp,${module.web_sg.security_group_id},MySQL from web servers"
  ]
  
  egress_rules_list = [
    "443,tcp,0.0.0.0/0,HTTPS for updates"
  ]
}
```

### 3. Application Load Balancer Security Group

```hcl
module "alb_sg" {
  source = "./security_group"
  
  region = var.region
  name   = "alb-sg-${var.environment}"
  vpc_id = var.vpc_id
  
  ingress_rules_list = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet"
  ]
}
```

### 4. Mixed Source Types

```hcl
module "app_sg" {
  source = "./security_group"
  
  region = var.region
  name   = "application-sg-${var.environment}"
  vpc_id = var.vpc_id
  
  ingress_rules_list = [
    "22,tcp,192.168.1.100/32,SSH from jump host",
    "3389,tcp,sg-0123456789abcdef0,RDP from admin SG",
    "443,tcp,pl-0123456789abcdef0,HTTPS via prefix list",
    "8080-8085,tcp,10.0.0.0/16,App ports from VPC"
  ]
}
```

## Migration from Existing Modules

This module is designed to be compatible with existing security group configurations in the EC2 and RDS modules. You can migrate by:

1. **From EC2 module**: Replace `sg_rules_ec2` with `ingress_rules_list`
2. **From RDS module**: Replace `sg_rules_rds` with `ingress_rules_list`
3. **Existing variable names**: Most variables follow the same naming convention

### Migration Example

**Before (EC2 module):**
```hcl
sg_rules_ec2 = [
  "22,tcp,10.8.126.221/32,SSH access",
  "80,tcp,0.0.0.0/0,HTTP access"
]
```

**After (Security Group module):**
```hcl
ingress_rules_list = [
  "22,tcp,10.8.126.221/32,SSH access",
  "80,tcp,0.0.0.0/0,HTTP access"
]
```

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

## Best Practices

1. **Use descriptive names**: Include environment and purpose in security group names
2. **Follow least privilege**: Only open ports that are actually needed
3. **Use specific CIDR blocks**: Avoid 0.0.0.0/0 when possible
4. **Group related rules**: Use separate security groups for different tiers (web, app, db)
5. **Document rules**: Always include meaningful descriptions
6. **Tag consistently**: Use the provided tagging variables for organization standards

## License

This module is maintained by the Infrastructure Team. For questions or issues, please contact the DevOps team.