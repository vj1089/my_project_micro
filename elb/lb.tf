
resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = var.load_balancer_type
  subnets            = var.lb_subnets
  enable_deletion_protection = var.lb_enable_deletion_protection
  
  dynamic "security_groups" {
    for_each = var.load_balancer_type == "application" ? [1] : []
    content {
      security_groups = [aws_security_group.sg_lb_dev.id]
    }
  }
  
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
    }
    tags = merge({ Name = "${var.lb_name}-TG-${var.lb_target_group_port[count.index]}" }, local.common_tags)
  }


  # Listener for ALB only
  resource "aws_lb_listener" "this" {
    count = var.load_balancer_type == "application" ? length(var.lb_target_group_port) : 0
    load_balancer_arn = aws_lb.this.arn
    port              = var.lb_target_group_port[count.index]
    protocol          = var.lb_listener_protocol
    ssl_policy        = var.lb_listener_ssl_policy
    certificate_arn   = var.lb_listener_certificate_arn

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[count.index].arn
    }
    depends_on = [aws_lb.this, aws_lb_target_group.this]
  }
   