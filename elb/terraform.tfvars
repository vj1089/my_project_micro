region    = "us-west-2"

#TAG Variables
it_owner = "Imran Bawany"  ##required
BPO = "Imran Bawany" ##required
 compliance = "Non-GxP" ##required
 application = "Harness" ##required
 environment = "D" ##required
 department = "GTS - Infrastructure and Operations" ##required

# EC2 variables #


lb_subnets =["subnet-00dbe5995075104cb","subnet-01a9a138e30e33f7c"]  #BG-MAIN Validation Web Tier - C and BG-MAIN Validation Web Tier - B
load_balancer_type = "application"

vpc_id = "vpc-00b3ea864e13387ef"  #bgne-test-vpc
lb_name = "bgus-global-harness-alb"
lb_target_group_port = ["443"]
sg_rules_alb = [
  "443,tcp,10.8.0.0/24,Allow private IP"
]

# Generalized ELB variables
lb_internal = true
lb_enable_deletion_protection = false
lb_target_group_protocol = "HTTP"   # For ALB: HTTP/HTTPS, for NLB: TCP/UDP
lb_target_type = "instance"         # For ALB: instance/ip, for NLB: instance/ip
lb_health_check_protocol = "HTTP"   # For ALB: HTTP/HTTPS, for NLB: TCP
lb_listener_protocol = "HTTPS"       # For ALB: HTTP/HTTPS, for NLB: TCP/TLS
# Use a literal value here. If null, the module will select a recommended default when protocol is HTTPS.
lb_listener_ssl_policy = null
# To use a specific ACM certificate, uncomment and set the ARN below. Otherwise the module will
# attempt to find an ACM certificate for `lb_domain` (default: "*.beigenecorp.net").
# lb_listener_certificate_arn = null   # For ALB HTTPS, e.g. "arn:aws:acm:..."
# Domain for ACM certificate lookup (optional, default is *.beigenecorp.net)
lb_domain = "*.beigenecorp.net"
