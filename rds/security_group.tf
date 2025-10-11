


# Create author security group #
resource "aws_security_group" "sg" {
  name = lower("${var.db_name}-sg-${var.environment}")
  description = "Terraform ec2 security group"
  vpc_id = var.vpc_id
  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress traffic from ${var.db_name} Dev RDS"
  }
  tags = merge({ Name = lower("${var.db_name}-rds-sg-${var.environment}")},local.common_tags)
}

resource "aws_security_group_rule" "sg_lb_rule" {
    count             = length(var.sg_rules_rds)
    type              = "ingress"
    from_port         = element(split(",", element(var.sg_rules_rds, count.index)), 0)
    to_port           = element(split(",", element(var.sg_rules_rds, count.index)), 0)
    protocol          = element(split(",", element(var.sg_rules_rds, count.index)), 1)
    cidr_blocks       = [element(split(",", element(var.sg_rules_rds, count.index)), 2)]
    security_group_id = aws_security_group.sg.id
    description       = element(split(",", element(var.sg_rules_rds, count.index)), 3)
    depends_on = [
      aws_security_group.sg
    ]
}