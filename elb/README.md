# ELB Terraform Module

This module provisions an AWS Elastic Load Balancer (ELB) that can be configured as either an Application Load Balancer (ALB) or a Network Load Balancer (NLB). It supports advanced features such as multiple listeners, listener rules, custom health checks, and tagging.

## Features
- Supports both ALB and NLB (`load_balancer_type`)
- Multiple listeners (HTTP, HTTPS, TCP, TLS)
- Listener rules (for ALB)
- Customizable target group health checks
- Custom tags for target groups and listeners
- Security group management (for ALB)
- Outputs for all key attributes (ARNs, DNS, etc.)

## Usage

### Basic Example (ALB)
```hcl
module "elb" {
  source = "./elb"

  region                = "us-west-2"
  it_owner              = "Kristina Kinard"
  BPO                   = "April Song"
  compliance            = "Non-GxP"
  application           = "OutSystems"
  environment           = "V"
  department            = "GTS - GA"
  lb_subnets            = ["subnet-9f5eb2c4", "subnet-58fc6c11"]
  load_balancer_type    = "application"
  vpc_id                = "vpc-1d4e687a"
  lb_name               = "bgus-global-outs-alb"
  lb_target_group_port  = ["443"]
  sg_rules_alb          = ["443,tcp,10.8.0.0/24,Allow private IP"]

  # Optional: Set the domain for ACM certificate lookup (default is *.beigenecorp.net)
  # If not set, the module will use the ACM certificate for *.beigenecorp.net
  # If you want to use a different domain, set lb_domain to your domain name
  # lb_domain = "my.custom.domain.com"
}
```

### Basic Example (NLB)
```hcl
module "elb" {
  source = "./elb"

  region                = "us-west-2"
  it_owner              = "Kristina Kinard"
  BPO                   = "April Song"
  compliance            = "Non-GxP"
  application           = "OutSystems"
  environment           = "V"
  department            = "GTS - GA"
  lb_subnets            = ["subnet-9f5eb2c4", "subnet-58fc6c11"]
  load_balancer_type    = "network"
  vpc_id                = "vpc-1d4e687a"
  lb_name               = "bgus-global-outs-nlb"
  lb_target_group_port  = ["443"]
  # Optional: security group rules for ALB. Leave unset or empty for NLB.
  # sg_rules_alb = ["443,tcp,10.8.0.0/24,Allow private IP"]
}
```

### Advanced Features (Optional)
Uncomment and set these in your `terraform.tfvars` to enable advanced features:
```hcl
# Multiple listeners
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
    # If you want to use a specific ACM certificate, set certificate_arn here
    # Otherwise, the module will use the ACM certificate for lb_domain
    # certificate_arn = "arn:aws:acm:..."
  }
]

# Listener rules (ALB only)
lb_listener_rules = [
  {
    listener_index     = 1
    priority           = 100
    type               = "path-pattern"
    value              = "/api/*"
    target_group_index = 0
  }
]

# Custom health check
lb_health_check = {
  interval            = 30
  timeout             = 5
  healthy_threshold   = 5
  unhealthy_threshold = 2
  matcher             = "200-399"
  path                = "/health"
}
# Use var.lb_health_check (map) to customize health check parameters for target groups.
# Example (optional):
lb_health_check = {
  interval            = 30
  timeout             = 5
  healthy_threshold   = 5
  unhealthy_threshold = 2
}

# Custom tags
listener_tags = {
  environment = "dev"
  team        = "platform"
}
tg_tags = {
  environment = "dev"
  team        = "platform"
}
```


## Variables
See `variables.tf` for all available variables and their descriptions.

- `lb_domain`: The domain to use for ACM certificate lookup. If not set, defaults to `*.beigenecorp.net`. The module will automatically use the ACM certificate for this domain for HTTPS listeners unless you specify a certificate ARN directly.

- `lb_health_check`: Optional map to customize target group health check parameters. Defaults are provided by the module.

- `sg_rules_alb`: Optional list of security-group rule strings for ALB. If empty or not set, no SG ingress rules are created.

- `lb_listener_ssl_policy`: If you set this variable to a non-null string it will be used. If left null and `lb_listener_protocol` is `HTTPS`, the module will choose a recommended default SSL policy automatically.

## Outputs
- `LB_Details`: Map with LB ID, DNS, Name, Target Group IDs/Ports, Listener IDs/Ports
- `ELBID`: Listener tags (for ALB)

## Notes
- Security groups are only attached for ALB.
- Listener rules and advanced listener features are only available for ALB.
- For NLB, only TCP/TLS listeners are supported and security groups are not used.

## Example tfvars
See `terraform.tfvars.example` for a full example including optional advanced features.

---

For any questions or issues, please refer to the comments in the example files or open an issue in your repository.
