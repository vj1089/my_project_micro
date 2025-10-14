data "aws_acm_certificate" "default" {
  domain      = var.lb_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

locals {
  # Determine effective SSL policy: use provided policy when set; if listener protocol is HTTPS and no policy set, use a recommended default.
  effective_ssl_policy = var.lb_listener_ssl_policy != null ? var.lb_listener_ssl_policy : (var.lb_listener_protocol == "HTTPS" ? "ELBSecurityPolicy-TLS13-1-2-2021-06" : null)
}

resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.lb_subnets
  enable_deletion_protection = var.lb_enable_deletion_protection

  security_groups = var.load_balancer_type == "application" ? [aws_security_group.sg_lb_dev.id] : null

  tags = merge({ Name = var.lb_name }, local.common_tags)
  depends_on = [aws_security_group.sg_lb_dev]
}


  resource "aws_lb_target_group" "this" {
    count = length(var.lb_target_group_port)
    name  = "${var.lb_name}-TG-${var.lb_target_group_port[count.index]}"
    port  = var.lb_target_group_port[count.index]
    protocol = var.lb_target_group_protocol
    vpc_id  = var.vpc_id
    target_type = var.lb_target_type
  
    health_check {
      port     = var.lb_target_group_port[count.index]
      protocol = var.lb_health_check_protocol
      interval            = lookup(var.lb_health_check, "interval", 30)
      timeout             = lookup(var.lb_health_check, "timeout", 5)
      healthy_threshold   = lookup(var.lb_health_check, "healthy_threshold", 5)
      unhealthy_threshold = lookup(var.lb_health_check, "unhealthy_threshold", 2)
      # Note: HTTP/HTTPS-specific options like `path` and `matcher` are intentionally omitted here
      # to keep the target group compatible with both ALB and NLB (TCP) target groups. If you need
      # HTTP-specific health checks, override the resource in your deployment or modify this module
      # to include `path`/`matcher` guarded by provider/version checks.
    }
    tags = merge({ Name = "${var.lb_name}-TG-${var.lb_target_group_port[count.index]}" }, local.common_tags)
  }


  # Listener for ALB only
  resource "aws_lb_listener" "this" {
    # create a listener per target port for both ALB and NLB. Protocol selection controls behavior.
    count = length(var.lb_target_group_port)
    load_balancer_arn = aws_lb.this.arn
    port              = var.lb_target_group_port[count.index]
  protocol          = var.lb_listener_protocol
  ssl_policy        = local.effective_ssl_policy
    # For HTTPS (ALB) or TLS (NLB), use provided certificate ARN or lookup via ACM; otherwise null
    certificate_arn   = (var.lb_listener_protocol == "HTTPS" || var.lb_listener_protocol == "TLS") ? (var.lb_listener_certificate_arn != null ? var.lb_listener_certificate_arn : data.aws_acm_certificate.default.arn) : null

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[count.index].arn
    }
    depends_on = [aws_lb.this, aws_lb_target_group.this]
  }
   