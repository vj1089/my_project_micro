# ELB (Elastic Load Balancer) Terraform Module

This Terraform module provisions AWS Elastic Load Balancers with support for both Application Load Balancers (ALB) and Network Load Balancers (NLB). The module provides comprehensive configuration options including multiple listeners, listener rules, health checks, SSL/TLS termination, and enterprise tagging standards.

## Features

- **Multi-Type Support**: Application Load Balancer (ALB) and Network Load Balancer (NLB)
- **Multiple Listeners**: HTTP, HTTPS, TCP, TLS protocol support
- **Advanced Routing**: Listener rules for path-based and host-based routing (ALB)
- **SSL/TLS Management**: Automatic ACM certificate integration and custom SSL policies
- **Health Check Configuration**: Customizable health check parameters
- **Security Group Integration**: CSV-format security rules for ALB traffic control
- **Comprehensive Tagging**: Built-in support for enterprise tagging standards
- **Target Group Management**: Flexible target group configuration
- **High Availability**: Multi-AZ deployment across multiple subnets

## Usage

### Basic Example - Application Load Balancer

```hcl
module "web_alb" {
  source = "./elb"

  # Basic configuration
  region             = "us-west-2"
  lb_name           = "web-app-alb-prod"
  load_balancer_type = "application"
  vpc_id            = "vpc-abc123def456"
  lb_subnets        = ["subnet-11111111", "subnet-22222222"]

  # Target groups
  lb_target_group_port = ["80", "443"]

  # Security configuration
  sg_rules_alb = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet"
  ]

  # SSL/TLS configuration
  lb_domain = "myapp.beigenecorp.net"  # Optional: defaults to *.beigenecorp.net

  # Required tagging
  application = "web-application"
  environment = "production"
  it_owner    = "Network Team"
  BPO         = "Application Owner"
  compliance  = "GxP"
  department  = "GTS - Infrastructure & Operations"
}
```

### Advanced Example - ALB with Multiple Listeners and Rules

```hcl
module "advanced_alb" {
  source = "./elb"

  # Basic configuration
  region             = "us-west-2"
  lb_name           = "advanced-alb-prod"
  load_balancer_type = "application"
  vpc_id            = var.vpc_id
  lb_subnets        = var.public_subnets

  # Target groups
  lb_target_group_port = ["80", "8080", "9000"]

  # Multiple listeners with different configurations
  lb_listeners = [
    {
      port            = 80
      protocol        = "HTTP"
      ssl_policy      = null
      certificate_arn = null
    },
    {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = null  # Will use lb_domain for auto-discovery
    },
    {
      port            = 8443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    }
  ]

  # Listener rules for path-based routing
  lb_listener_rules = [
    {
      listener_index     = 1  # HTTPS listener (index 1)
      priority           = 100
      type               = "path-pattern"
      value              = "/api/*"
      target_group_index = 1  # Route API traffic to second target group
    },
    {
      listener_index     = 1
      priority           = 200
      type               = "host-header"
      value              = "admin.myapp.beigenecorp.net"
      target_group_index = 2  # Route admin traffic to third target group
    }
  ]

  # Custom health check configuration
  lb_health_check = {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
    path                = "/health"
  }

  # Security configuration
  sg_rules_alb = [
    "80,tcp,0.0.0.0/0,HTTP from internet",
    "443,tcp,0.0.0.0/0,HTTPS from internet",
    "8443,tcp,10.0.0.0/8,Admin HTTPS from internal"
  ]

  # Domain for ACM certificate lookup
  lb_domain = "myapp.beigenecorp.net"

  # Custom tags
  listener_tags = {
    Environment = "production"
    Team        = "platform"
  }
  
  tg_tags = {
    Environment = "production"
    Team        = "platform"
  }

  # Required tagging
  application = "web-platform"
  environment = "production"
  it_owner    = "Platform Team"
  BPO         = "Platform Owner"
  compliance  = "GxP"
  department  = "GTS - Infrastructure & Operations"
}
```

### Network Load Balancer Example

```hcl
module "network_lb" {
  source = "./elb"

  # Basic configuration
  region             = "us-west-2"
  lb_name           = "app-nlb-prod"
  load_balancer_type = "network"
  vpc_id            = var.vpc_id
  lb_subnets        = var.private_subnets

  # Target groups for NLB
  lb_target_group_port = ["443", "3306"]

  # NLB listeners
  lb_listeners = [
    {
      port            = 443
      protocol        = "TLS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
    },
    {
      port            = 3306
      protocol        = "TCP"
      ssl_policy      = null
      certificate_arn = null
    }
  ]

  # Custom health check for database traffic
  lb_health_check = {
    interval            = 10
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  # Note: Security groups not applicable for NLB
  # sg_rules_alb = []  # Leave empty or omit for NLB

  # Required tagging
  application = "database-cluster"
  environment = "production"
  it_owner    = "Database Team"
  BPO         = "Data Management"
  compliance  = "GxP"
  department  = "GTS - Infrastructure & Operations"
}
```

## Load Balancer Types

### Application Load Balancer (ALB)
- **Layer**: Application Layer (Layer 7)
- **Protocols**: HTTP, HTTPS
- **Features**: Content-based routing, SSL termination, WebSockets, HTTP/2
- **Use Cases**: Web applications, microservices, container workloads
- **Security Groups**: Required and managed by module

### Network Load Balancer (NLB)
- **Layer**: Transport Layer (Layer 4)
- **Protocols**: TCP, TLS, UDP
- **Features**: Ultra-low latency, static IPs, millions of requests per second
- **Use Cases**: High-performance applications, gaming, IoT, database connections
- **Security Groups**: Not applicable (traffic flows directly to targets)

## Security Group Rules Format (ALB Only)

For Application Load Balancers, the module accepts security group rules in CSV format:

### Rule Format
`"<port>,<protocol>,<source>,<description>"`

### Examples

```hcl
sg_rules_alb = [
  # Standard web traffic
  "80,tcp,0.0.0.0/0,HTTP from internet",
  "443,tcp,0.0.0.0/0,HTTPS from internet",
  
  # Internal traffic
  "8080,tcp,10.0.0.0/16,Application port from VPC",
  
  # Admin access
  "9443,tcp,192.168.1.0/24,Admin HTTPS from office network",
  
  # Security group reference
  "443,tcp,sg-0123456789abcdef0,HTTPS from specific security group"
]
```

## SSL/TLS Configuration

### Automatic Certificate Discovery
The module can automatically discover ACM certificates:

```hcl
# Uses ACM certificate for *.beigenecorp.net (default)
lb_domain = "*.beigenecorp.net"

# Or specify a custom domain
lb_domain = "myapp.example.com"
```

### Explicit Certificate ARN
For specific certificate control:

```hcl
lb_listeners = [
  {
    port            = 443
    protocol        = "HTTPS"
    ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
]
```

### SSL Policies
Recommended SSL policies:
- `ELBSecurityPolicy-TLS13-1-2-2021-06` (Latest, most secure)
- `ELBSecurityPolicy-FS-1-2-2019-08` (Forward Secrecy)
- `ELBSecurityPolicy-2016-08` (Legacy compatibility)

## Best Practices

1. **Load Balancer Type Selection**: Use ALB for HTTP/HTTPS workloads, NLB for high-performance TCP/UDP
2. **SSL/TLS Security**: Always use the latest SSL policies and enable HTTPS redirection
3. **Health Checks**: Configure appropriate health check intervals and thresholds
4. **Target Distribution**: Distribute targets across multiple Availability Zones
5. **Security Groups**: Use least privilege principles for ALB security group rules
6. **Monitoring**: Enable access logs and CloudWatch metrics for performance monitoring
7. **Certificate Management**: Use ACM for certificate management and automatic renewal

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Support

For questions, issues, or contributions:

1. **Internal Support**: Contact the Network Team
2. **Documentation**: Check the `terraform.tfvars.example` files for detailed configuration examples
3. **SSL/TLS**: Ensure certificates are properly configured in ACM
4. **Testing**: Test load balancer functionality in development before production deployment

## License

This module is maintained by the Infrastructure Team. For questions or issues, please contact the DevOps team.
