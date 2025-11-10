# RDS Terraform Module

This Terraform module provisions AWS RDS instances with secure defaults, multi-engine support, and comprehensive configuration options. The module supports MySQL, PostgreSQL, and SQL Server databases with enterprise-grade security, encryption, and tagging standards.

## Features

- **Multi-Engine Support**: MySQL, PostgreSQL, and SQL Server database engines
- **Security by Default**: Storage encryption enabled with KMS key management
- **High Availability**: Multi-AZ deployment support for production workloads
- **Flexible Configuration**: Customizable instance types, storage, and engine versions
- **Security Group Integration**: CSV-format security rules for database access control
- **Comprehensive Tagging**: Built-in support for enterprise tagging standards
- **Backup & Recovery**: Automated backup configuration with retention policies
- **Parameter Groups**: Engine-specific parameter group management
- **Subnet Groups**: Multi-subnet deployment for high availability

## Usage

### Basic Example - MySQL Database

```hcl
module "mysql_database" {
  source = "./rds"

  # Basic configuration
  region                 = "us-west-2"
  db_engine             = "mysql"
  db_engine_version     = "8.0"
  db_engine_minorVersion = "42"
  db_name               = "application_db"
  db_instance_type      = "db.t3.medium"
  db_username           = "admin"
  db_password           = var.db_password  # Use variable for security
  db_storage            = 100

  # High availability
  multi_az = true

  # Network configuration
  vpc_id    = "vpc-abc123def456"
  subnet_id = ["subnet-11111111", "subnet-22222222"]

  # Security group rules
  sg_rules_rds = [
    "3306,tcp,10.0.0.0/16,MySQL from application subnets",
    "3306,tcp,sg-0123456789abcdef0,MySQL from web servers"
  ]

  # Required tagging
  application = "web-application"
  environment = "production"
  it_owner    = "Database Team"
  BPO         = "Application Owner"
  compliance  = "GxP"
  department  = "GTS - Infrastructure & Operations"
}
```

### Advanced Example - PostgreSQL with Custom Configuration

```hcl
module "postgres_database" {
  source = "./rds"

  # Database configuration
  region                 = var.region
  db_engine             = "postgres"
  db_engine_version     = "15"
  db_engine_minorVersion = "4"
  db_name               = "analytics_db"
  db_instance_type      = "db.r5.xlarge"
  db_username           = "postgres"
  db_password           = var.postgres_password
  db_storage            = 500

  # Performance and availability
  multi_az              = true
  backup_retention_period = 30
  backup_window         = "03:00-04:00"
  maintenance_window    = "sun:04:00-sun:05:00"

  # Network configuration
  vpc_id    = var.vpc_id
  subnet_id = var.database_subnets

  # Security configuration
  sg_rules_rds = [
    "5432,tcp,${var.app_cidr},PostgreSQL from application tier",
    "5432,tcp,${var.admin_cidr},PostgreSQL from admin network"
  ]

  # Storage configuration
  storage_type          = "gp3"
  storage_encrypted     = true
  iops                  = 3000
  throughput            = 125

  # Tagging
  application = "analytics"
  environment = var.environment
  it_owner    = "Data Team"
  BPO         = "Analytics Owner"
  compliance  = "GxP"
  department  = "GTS - Infrastructure & Operations"
}
```

## Database Engine Support

### MySQL
- **Supported Versions**: 8.0.x, 5.7.x
- **Default Port**: 3306
- **Features**: InnoDB storage engine, automated backups, read replicas
- **Best For**: Web applications, content management, e-commerce

### PostgreSQL
- **Supported Versions**: 15.x, 14.x, 13.x
- **Default Port**: 5432
- **Features**: Advanced SQL features, JSON support, extensions
- **Best For**: Analytics, data warehousing, complex queries

### SQL Server
- **Supported Versions**: 2019, 2017, 2016
- **Default Port**: 1433
- **Features**: Enterprise features, Always On, T-SQL support
- **Best For**: Enterprise applications, .NET applications, business intelligence

## Security Group Rules Format

The module accepts security group rules in CSV format through the `sg_rules_rds` variable:

### Rule Format
`"<port>,<protocol>,<source>,<description>"`

### Examples

```hcl
sg_rules_rds = [
  # MySQL access from application subnets
  "3306,tcp,10.0.100.0/24,MySQL from app subnet",
  
  # PostgreSQL access from specific security group
  "5432,tcp,sg-0123456789abcdef0,PostgreSQL from app servers",
  
  # SQL Server access from admin network
  "1433,tcp,192.168.1.0/24,SQL Server from admin network",
  
  # Multiple database ports for different applications
  "3306,tcp,10.0.0.0/16,MySQL from VPC",
  "5432,tcp,10.0.0.0/16,PostgreSQL from VPC"
]
```

## KMS Encryption

The module uses AWS-managed RDS encryption by default:

### Default Configuration
- **KMS Key**: AWS-managed key (`aws/rds`)
- **Encryption**: Storage encryption enabled by default
- **Automatic**: Region-agnostic alias resolution

### Custom KMS Key
To use a customer-managed KMS key, update the data source in `datastore.tf`:

```hcl
data "aws_kms_alias" "rds_key" {
  name = "alias/my-custom-rds-key"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | AWS region where the RDS instance will be created | `string` | n/a | yes |
| db_engine | Database engine (mysql, postgres, sqlserver) | `string` | n/a | yes |
| db_engine_version | Database engine version | `string` | n/a | yes |
| db_engine_minorVersion | Database engine minor version | `string` | n/a | yes |
| db_name | Name of the database | `string` | n/a | yes |
| db_instance_type | RDS instance type | `string` | n/a | yes |
| db_username | Master username for the database | `string` | n/a | yes |
| db_password | Master password for the database | `string` | n/a | yes |
| db_storage | Allocated storage in GB | `number` | n/a | yes |
| vpc_id | VPC ID where the RDS instance will be created | `string` | n/a | yes |
| subnet_id | List of subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| sg_rules_rds | List of security group rules in CSV format | `list(string)` | `[]` | no |
| multi_az | Enable Multi-AZ deployment | `bool` | `false` | no |
| storage_type | Storage type (gp2, gp3, io1, io2) | `string` | `"gp2"` | no |
| storage_encrypted | Enable storage encryption | `bool` | `true` | no |
| backup_retention_period | Backup retention period in days | `number` | `7` | no |
| backup_window | Preferred backup window | `string` | `"03:00-04:00"` | no |
| maintenance_window | Preferred maintenance window | `string` | `"sun:04:00-sun:05:00"` | no |
| skip_final_snapshot | Skip final snapshot when deleting | `bool` | `false` | no |
| deletion_protection | Enable deletion protection | `bool` | `true` | no |
| application | Application name for tagging | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| it_owner | IT Owner for tagging | `string` | n/a | yes |
| BPO | Business Process Owner | `string` | n/a | yes |
| compliance | Compliance requirement (GxP, Non-GxP) | `string` | n/a | yes |
| department | Department responsible for the resource | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | RDS instance identifier |
| db_instance_arn | ARN of the RDS instance |
| db_instance_endpoint | RDS instance endpoint |
| db_instance_hosted_zone_id | Hosted zone ID of the RDS instance |
| db_instance_port | Port of the RDS instance |
| db_instance_name | Database name |
| db_subnet_group_id | DB subnet group identifier |
| db_subnet_group_arn | ARN of the DB subnet group |
| db_parameter_group_id | DB parameter group identifier |
| security_group_id | ID of the created security group |
| security_group_arn | ARN of the created security group |

## Best Practices

1. **Security First**: Always use strong passwords and store them securely (AWS Secrets Manager, variables)
2. **High Availability**: Use Multi-AZ for production workloads
3. **Backup Strategy**: Configure appropriate backup retention periods
4. **Performance Monitoring**: Monitor CPU, memory, and storage metrics
5. **Network Security**: Use security groups to restrict database access
6. **Encryption**: Enable storage encryption for sensitive data
7. **Version Management**: Keep database engines updated with minor version upgrades
8. **Resource Sizing**: Right-size instances based on actual workload requirements

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Troubleshooting

### Common Issues

1. **KMS Key Not Found**
   - Verify KMS alias exists: `aws kms list-aliases --region <region>`
   - Check that the alias `aws/rds` is available in your account

2. **Database Engine Version Issues**
   - Verify engine version compatibility: `aws rds describe-db-engine-versions --engine mysql`
   - Check minor version availability in your region

3. **Subnet Group Creation Errors**
   - Ensure subnets are in different Availability Zones for Multi-AZ
   - Verify all subnet IDs exist and are in the same VPC

4. **Security Group Rule Errors**
   - Verify CSV format: `"port,protocol,source,description"`
   - Check that referenced security group IDs exist
   - Ensure CIDR blocks are valid

5. **Connection Issues**
   - Verify security group allows traffic from your source
   - Check database endpoint and port configuration
   - Ensure database is in "available" state

### Debug Commands

```bash
# Check RDS engine versions
aws rds describe-db-engine-versions --engine mysql --query "DBEngineVersions[*].[EngineVersion,DBParameterGroupFamily]"

# Verify subnet availability
aws ec2 describe-subnets --subnet-ids subnet-12345 subnet-67890

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345

# Monitor RDS instance status
aws rds describe-db-instances --db-instance-identifier my-database
```

## Support

For questions, issues, or contributions:

1. **Internal Support**: Contact the Database Team
2. **Documentation**: Check the `terraform.tfvars.example` for detailed configuration examples
3. **Security**: Never commit passwords or sensitive data to version control
4. **Testing**: Test database connectivity and performance in development before production deployment

## License

This module is maintained by the Infrastructure Team. For questions or issues, please contact the DevOps team.
