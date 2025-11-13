# Quick Start Examples

Common deployment scenarios using the multi-resource framework.

> **💡 Works with Terraform and OpenTofu**: All examples work identically with both tools. Just use `terraform` or `tofu` CLI commands.

## Example 1: Simple Web Application Stack

Deploy a web server, application server, database, and load balancer.

### resources.yaml

```yaml
common:
  region: "us-west-2"
  vpc_id: "vpc-0123456789"
  environment: "prod"
  
  common_tags:
    it_owner: "Platform Team"
    department: "Engineering"
    project: "WebApp"

ec2_instances:
  web-server:
    enabled: true
    instance_name: "webapp-web-01"
    ami_id: "ami-0abcdef1234567890"
    instance_type: "t3.medium"
    key_name: "webapp-key"
    subnet_id: "subnet-web-1"
    os_type: "linux"
    
    tags:
      Name: "webapp-web-01"
      BPO: "Web Team"
      compliance: "Non-GxP"
      RPO: 24
      RTO: 24
      application: "WebApp"
      tier: "web"
    
    security_group_rules:
      - "80,tcp,0.0.0.0/0,HTTP"
      - "443,tcp,0.0.0.0/0,HTTPS"

rds_instances:
  webapp-db:
    enabled: true
    identifier: "webapp-mysql"
    engine: "mysql"
    engine_version: "8.0.35"
    instance_class: "db.t3.medium"
    allocated_storage: 100
    master_username: "admin"
    subnet_ids:
      - "subnet-db-1"
      - "subnet-db-2"
    multi_az: true
    
    tags:
      Name: "webapp-mysql"
      BPO: "Database Team"
      compliance: "Non-GxP"
      application: "WebApp"

load_balancers:
  webapp-alb:
    enabled: true
    name: "webapp-alb"
    internal: false
    subnet_ids:
      - "subnet-public-1"
      - "subnet-public-2"
    
    target_group:
      name: "webapp-tg"
      port: 80
      protocol: "HTTP"
      health_check:
        path: "/health"
      targets:
        - instance_key: "web-server"
          port: 80
    
    tags:
      Name: "webapp-alb"
      application: "WebApp"
```

### Deploy

**With Terraform:**
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**With OpenTofu:**
```bash
tofu init
tofu plan
tofu apply -auto-approve
```

---

## Example 2: Multi-Tier Application (3-Tier)

Web tier → App tier → Database tier

### resources.yaml

```yaml
common:
  region: "us-west-2"
  vpc_id: "vpc-0123456789"
  environment: "prod"

ec2_instances:
  # Web Tier
  web-01:
    enabled: true
    instance_name: "web-server-01"
    ami_id: "ami-web"
    instance_type: "t3.medium"
    subnet_id: "subnet-web-1"
    tags:
      tier: "web"
      application: "ThreeTierApp"
  
  web-02:
    enabled: true
    instance_name: "web-server-02"
    ami_id: "ami-web"
    instance_type: "t3.medium"
    subnet_id: "subnet-web-2"
    tags:
      tier: "web"
      application: "ThreeTierApp"
  
  # App Tier
  app-01:
    enabled: true
    instance_name: "app-server-01"
    ami_id: "ami-app"
    instance_type: "t3.large"
    subnet_id: "subnet-app-1"
    tags:
      tier: "application"
      application: "ThreeTierApp"
    security_group_rules:
      - "8080,tcp,sg-web-tier,From Web"
  
  app-02:
    enabled: true
    instance_name: "app-server-02"
    ami_id: "ami-app"
    instance_type: "t3.large"
    subnet_id: "subnet-app-2"
    tags:
      tier: "application"
      application: "ThreeTierApp"

rds_instances:
  # Database Tier
  primary-db:
    enabled: true
    identifier: "primary-mysql"
    engine: "mysql"
    instance_class: "db.r5.xlarge"
    allocated_storage: 500
    multi_az: true
    tags:
      tier: "database"
      application: "ThreeTierApp"

load_balancers:
  # Web ALB (Internet-facing)
  web-alb:
    enabled: true
    name: "web-alb"
    internal: false
    subnet_ids: ["subnet-public-1", "subnet-public-2"]
    target_group:
      targets:
        - instance_key: "web-01"
        - instance_key: "web-02"
    tags:
      tier: "web"
  
  # App ALB (Internal)
  app-alb:
    enabled: true
    name: "app-alb"
    internal: true
    subnet_ids: ["subnet-app-1", "subnet-app-2"]
    target_group:
      port: 8080
      targets:
        - instance_key: "app-01"
        - instance_key: "app-02"
    tags:
      tier: "application"
```

---

## Example 3: Development Environment (Cost-Optimized)

Smaller instances for dev/test.

### resources-dev.yaml

```yaml
common:
  region: "us-west-2"
  vpc_id: "vpc-dev"
  environment: "dev"

ec2_instances:
  dev-server:
    enabled: true
    instance_name: "dev-server-01"
    ami_id: "ami-dev"
    instance_type: "t3.small"  # Smaller for dev
    subnet_id: "subnet-dev-1"
    root_vol_size: "50"  # Smaller disk
    tags:
      application: "Development"
      auto_shutdown: "true"  # Auto-shutdown at night

rds_instances:
  dev-db:
    enabled: true
    identifier: "dev-mysql"
    engine: "mysql"
    instance_class: "db.t3.micro"  # Smallest instance
    allocated_storage: 20
    multi_az: false  # No HA for dev
    tags:
      application: "Development"

load_balancers:
  dev-alb:
    enabled: false  # No ALB needed for dev
```

### Deploy

**With Terraform:**
```bash
terraform apply -var="resources_config_file=resources-dev.yaml"
```

**With OpenTofu:**
```bash
tofu apply -var="resources_config_file=resources-dev.yaml"
```

---

## Example 4: Gradual Rollout (Blue-Green)

Deploy new version alongside current.

### Step 1: Current (Blue) Environment

```yaml
ec2_instances:
  web-blue-01:
    enabled: true
    instance_name: "web-blue-01"
    ami_id: "ami-v1.0"  # Current version
    tags:
      version: "1.0"
      environment: "blue"
  
  web-blue-02:
    enabled: true
    instance_name: "web-blue-02"
    ami_id: "ami-v1.0"
    tags:
      version: "1.0"
      environment: "blue"

load_balancers:
  main-alb:
    target_group:
      targets:
        - instance_key: "web-blue-01"
        - instance_key: "web-blue-02"
```

### Step 2: Deploy Green Environment

```yaml
ec2_instances:
  # Blue (keep running)
  web-blue-01:
    enabled: true
  web-blue-02:
    enabled: true
  
  # Green (new version)
  web-green-01:
    enabled: true
    instance_name: "web-green-01"
    ami_id: "ami-v2.0"  # New version
    tags:
      version: "2.0"
      environment: "green"
  
  web-green-02:
    enabled: true
    instance_name: "web-green-02"
    ami_id: "ami-v2.0"
    tags:
      version: "2.0"
      environment: "green"
```

### Step 3: Switch Traffic to Green

```yaml
load_balancers:
  main-alb:
    target_group:
      targets:
        - instance_key: "web-green-01"  # Switch to green
        - instance_key: "web-green-02"
```

### Step 4: Decommission Blue

```yaml
ec2_instances:
  web-blue-01:
    enabled: false  # Remove blue
  web-blue-02:
    enabled: false
  
  web-green-01:
    enabled: true
  web-green-02:
    enabled: true
```

---

## Example 5: Disaster Recovery Setup

Primary and DR regions.

### resources-primary.yaml (us-west-2)

```yaml
common:
  region: "us-west-2"
  vpc_id: "vpc-primary"
  environment: "prod"

ec2_instances:
  app-primary-01:
    enabled: true
    instance_name: "app-primary-01"
    tags:
      dr_role: "primary"

rds_instances:
  primary-db:
    enabled: true
    identifier: "app-db-primary"
    multi_az: true
    tags:
      dr_role: "primary"
```

### resources-dr.yaml (us-east-1)

```yaml
common:
  region: "us-east-1"
  vpc_id: "vpc-dr"
  environment: "prod"

ec2_instances:
  app-dr-01:
    enabled: false  # Standby, enable during failover
    instance_name: "app-dr-01"
    tags:
      dr_role: "standby"

rds_instances:
  dr-db:
    enabled: true  # Read replica
    identifier: "app-db-dr"
    tags:
      dr_role: "standby"
```

### Failover Process

1. Enable DR instances: Set `enabled: true`
2. Apply changes
3. Update DNS/Route53 to point to DR region
4. Promote RDS read replica to primary

---

## Example 6: Auto-Scaling Ready

Prepare for auto-scaling groups.

### resources.yaml

```yaml
ec2_instances:
  # Launch template instances (used as templates)
  web-template:
    enabled: false  # Don't create, just define
    instance_name: "web-template"
    ami_id: "ami-latest"
    instance_type: "t3.medium"
    tags:
      purpose: "launch_template"

# When you add ASG module support:
autoscaling_groups:
  web-asg:
    enabled: true
    name: "web-asg"
    template_reference: "web-template"  # Reference EC2 config
    min_size: 2
    max_size: 10
    desired_capacity: 3
    target_group_arn: "arn:from-alb"
```

---

## Example 7: Scheduled Scaling

Different sizes at different times.

### Business Hours (8 AM - 6 PM)

```yaml
ec2_instances:
  app-01:
    enabled: true
    instance_type: "t3.large"  # Larger during business hours
  
  app-02:
    enabled: true
    instance_type: "t3.large"
  
  app-03:
    enabled: true  # Extra instance
    instance_type: "t3.large"
```

### Off Hours (6 PM - 8 AM)

```yaml
ec2_instances:
  app-01:
    enabled: true
    instance_type: "t3.small"  # Smaller off-hours
  
  app-02:
    enabled: true
    instance_type: "t3.small"
  
  app-03:
    enabled: false  # Shutdown extra instance
```

Use Harness scheduled triggers to apply different configs.

---

## Example 8: Compliance-Driven Tagging

Different compliance requirements per resource.

```yaml
ec2_instances:
  public-web:
    enabled: true
    tags:
      compliance: "Non-GxP"
      data_classification: "Public"
      RPO: 24
      RTO: 24
      backup_required: "false"
  
  patient-data-app:
    enabled: true
    tags:
      compliance: "GxP"
      data_classification: "PHI"
      RPO: 4
      RTO: 4
      backup_required: "true"
      encryption_required: "true"
      audit_logging: "enabled"
```

---

## Example 9: Multi-Account Deployment

Deploy to different AWS accounts.

### Account A (Development)

```yaml
common:
  region: "us-west-2"
  account_id: "111111111111"
  environment: "dev"
```

### Account B (Production)

```yaml
common:
  region: "us-west-2"
  account_id: "222222222222"
  environment: "prod"
```

In Harness, use different AWS connectors per environment.

---

## Example 10: Resource Dependencies

Resources that depend on each other.

```yaml
ec2_instances:
  bastion:
    enabled: true
    instance_name: "bastion"
    subnet_id: "subnet-public-1"  # Public subnet
    security_group_rules:
      - "22,tcp,0.0.0.0/0,SSH Access"
  
  app-server:
    enabled: true
    instance_name: "app-server"
    subnet_id: "subnet-private-1"  # Private subnet
    security_group_rules:
      - "22,tcp,sg-bastion,SSH from Bastion"  # Depends on bastion SG

rds_instances:
  app-db:
    enabled: true
    security_group_rules:
      - "3306,tcp,sg-app-server,From App"  # Depends on app server SG
```

Terraform automatically handles dependency order.

---

## Tips for Creating Your Own Examples

1. **Start Small**: Begin with 1-2 resources, validate, then expand
2. **Use enabled: false**: Define resources first, test with `enabled: false`
3. **Leverage Defaults**: Use `try()` in main.tf for optional fields
4. **Tag Everything**: Consistent tagging helps tracking and cost allocation
5. **Test in Dev First**: Always test in dev before applying to prod
6. **Version Control**: Commit your YAML configs to Git
7. **Document**: Add comments in YAML explaining design decisions

## Need More Examples?

Check:
- [README.md](./README.md) - Main documentation
- [EXTENDING.md](./EXTENDING.md) - Adding new resource types
- [HARNESS_INTEGRATION.md](./HARNESS_INTEGRATION.md) - Harness setup
