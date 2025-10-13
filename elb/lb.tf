resource "aws_lb" "alb-dev" {
    name                       = var.lb_name
    internal                   = true
    load_balancer_type         = var.load_balancer_type
    # enable_cross_zone          = true
    subnets                    = var.lb_subnets
    security_groups            = [aws_security_group.sg_lb_dev.id]
    enable_deletion_protection = false
     
    tags = merge({ Name = "${var.lb_name}"},local.common_tags)
    depends_on = [
            aws_security_group.sg_lb_dev
            ]
   }

  resource "aws_lb_target_group" "alb-dev-tg1"{
    count = length(var.lb_target_group_port)
    name                              = "${var.lb_name}-TG-${var.lb_target_group_port[count.index]}"
    load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
    port                              = var.lb_target_group_port[count.index]
    protocol                          = "HTTPS" ##change to HTTP or HTTPS as per the client port
    vpc_id                            = var.vpc_id
    #target_type = "ip" ##Use only if in diffrent VPC external
    health_check {
      port     = var.lb_target_group_port[count.index]
      protocol = "HTTPS"    ##change to HTTP or HTTPS as per the client port
    }
    tags = merge({ Name = "${var.lb_name}-TG-${var.lb_target_group_port[count.index]}"},local.common_tags)
    
   }

   resource "aws_lb_listener" "dev-listener" {
    count = length(var.lb_target_group_port)
    load_balancer_arn = aws_lb.alb-dev.arn
    port              = var.lb_target_group_port[count.index]
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" #"ELBSecurityPolicy-2016-08"
    certificate_arn   = "arn:aws:acm:us-west-2:436207872885:certificate/203ed4a9-7c7f-411d-8077-61af4c26aeae"#"arn:aws-cn:acm:cn-north-1:256848935116:certificate/54efc06d-52d9-48c3-9eb2-1050b3d13ee2"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.alb-dev-tg1[count.index].arn
    }
    depends_on = [
      aws_lb.alb-dev,
      aws_lb_target_group.alb-dev-tg1
    ]
  }
   