


# Create author security group #
resource "aws_security_group" "sg_lb_dev" {
  name = lower("${var.lb_name}-sg")
  description = "Terraform LB security group"
  vpc_id = var.vpc_id
  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = lower("${var.lb_name}-sg")},local.common_tags)
}

resource "aws_security_group_rule" "sg_lb_rule" {
    count             = length(var.sg_rules_alb)
    type              = "ingress"
    from_port         = element(split(",", element(var.sg_rules_alb, count.index)), 0)
    to_port           = element(split(",", element(var.sg_rules_alb, count.index)), 0)
    protocol          = element(split(",", element(var.sg_rules_alb, count.index)), 1)
    cidr_blocks       = [element(split(",", element(var.sg_rules_alb, count.index)), 2)]
    security_group_id = aws_security_group.sg_lb_dev.id
  description       = "LB ingress traffic from user for ${var.application} Application"
    depends_on = [
      aws_security_group.sg_lb_dev
    ]
  }