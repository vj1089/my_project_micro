
# Create author security group #
resource "aws_security_group" "sg" {
  name = lower("${var.instance_name}-sg-${var.environment}")
  description = "Terraform ec2 security group"
  vpc_id = var.vpc_id
  # Egress rule allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = lower("${var.instance_name}-sg-${var.environment}")}, local.resource_tags)
}
locals {
  # Pre-parse the CSV-style sg_rules list into lists of fields so we can reference by index
  sg_rules_parsed = [for r in var.sg_rules_ec2 : split(",", r)]
}

resource "aws_security_group_rule" "sg_lb_rule" {
  count             = length(var.sg_rules_ec2)
  type              = "ingress"

  # support single-port ("22") or port-range ("1024-2048") in field 0
  from_port = tonumber(split("-", local.sg_rules_parsed[count.index][0])[0])
  to_port   = tonumber(length(split("-", local.sg_rules_parsed[count.index][0])) > 1 ? split("-", local.sg_rules_parsed[count.index][0])[1] : split("-", local.sg_rules_parsed[count.index][0])[0])

  protocol = local.sg_rules_parsed[count.index][1]

  # field 2 may be a CIDR, an SG id (sg-...) or a prefix list id (pl-...)
  # set the appropriate attribute based on the prefix
  cidr_blocks = (startswith(local.sg_rules_parsed[count.index][2], "sg-") || startswith(local.sg_rules_parsed[count.index][2], "pl-")) ? [] : [local.sg_rules_parsed[count.index][2]]
  prefix_list_ids = startswith(local.sg_rules_parsed[count.index][2], "pl-") ? [local.sg_rules_parsed[count.index][2]] : []
  source_security_group_id = startswith(local.sg_rules_parsed[count.index][2], "sg-") ? local.sg_rules_parsed[count.index][2] : null

  security_group_id = aws_security_group.sg.id

  description = length(local.sg_rules_parsed[count.index]) > 3 ? local.sg_rules_parsed[count.index][3] : ""

  depends_on = [
    aws_security_group.sg
  ]
}