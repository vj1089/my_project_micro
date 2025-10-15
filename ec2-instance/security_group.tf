
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

locals {
  # Map of parsed rules keyed by index (string) to make for_each selections easy
  # normalize each parsed rule into an object with trimmed fields
  sg_rules_map = {
    for idx, parts in local.sg_rules_parsed : tostring(idx) => {
      port_field  = trimspace(parts[0])
      protocol    = trimspace(parts[1])
      source      = length(parts) > 2 ? trimspace(parts[2]) : ""
      description = length(parts) > 3 ? trimspace(parts[3]) : ""
    }
  }

  cidr_rules = { for k, r in local.sg_rules_map : k => r if !(startswith(r.source, "sg-") || startswith(r.source, "pl-")) }
  sgid_rules = { for k, r in local.sg_rules_map : k => r if startswith(r.source, "sg-") }
  prefix_rules = { for k, r in local.sg_rules_map : k => r if startswith(r.source, "pl-") }
}

resource "aws_security_group_rule" "cidr" {
  for_each = local.cidr_rules
  type     = "ingress"

  from_port = tonumber(split("-", each.value.port_field)[0])
  to_port   = tonumber(length(split("-", each.value.port_field)) > 1 ? split("-", each.value.port_field)[1] : split("-", each.value.port_field)[0])

  protocol   = each.value.protocol
  cidr_blocks = [each.value.source]

  security_group_id = aws_security_group.sg.id
  description = length(each.value) > 3 ? each.value[3] : ""

  depends_on = [aws_security_group.sg]
}

resource "aws_security_group_rule" "sgid" {
  for_each = local.sgid_rules
  type     = "ingress"

  from_port = tonumber(split("-", each.value.port_field)[0])
  to_port   = tonumber(length(split("-", each.value.port_field)) > 1 ? split("-", each.value.port_field)[1] : split("-", each.value.port_field)[0])

  protocol = each.value.protocol
  source_security_group_id = each.value.source

  security_group_id = aws_security_group.sg.id
  description = length(each.value) > 3 ? each.value[3] : ""

  depends_on = [aws_security_group.sg]
}

resource "aws_security_group_rule" "prefix" {
  for_each = local.prefix_rules
  type     = "ingress"

  from_port = tonumber(split("-", each.value.port_field)[0])
  to_port   = tonumber(length(split("-", each.value.port_field)) > 1 ? split("-", each.value.port_field)[1] : split("-", each.value.port_field)[0])

  protocol = each.value.protocol
  prefix_list_ids = [each.value.source]

  security_group_id = aws_security_group.sg.id
  description = each.value.description

  depends_on = [aws_security_group.sg]
}