# Main Security Group Module
# This module creates AWS security groups with flexible ingress and egress rules

# Create the main security group
resource "aws_security_group" "this" {
  name_prefix = var.name_prefix != "" ? var.name_prefix : null
  name        = var.name != "" ? var.name : null
  description = var.description
  vpc_id      = var.vpc_id

  # Default egress rule allowing all outbound traffic (can be overridden)
  dynamic "egress" {
    for_each = var.create_default_egress ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all egress traffic"
    }
  }

  tags = merge(
    {
      Name = var.name != "" ? var.name : "${var.name_prefix}${random_id.sg_suffix[0].hex}"
    },
    local.resource_tags,
    var.additional_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Generate random suffix for name_prefix usage
resource "random_id" "sg_suffix" {
  count       = var.name_prefix != "" && var.name == "" ? 1 : 0
  byte_length = 4
}

# Create ingress rules from list format (similar to existing modules)
resource "aws_security_group_rule" "ingress_list" {
  for_each = local.ingress_rules_map
  type     = "ingress"

  from_port = tonumber(split("-", each.value.port_field)[0])
  to_port   = tonumber(length(split("-", each.value.port_field)) > 1 ? split("-", each.value.port_field)[1] : split("-", each.value.port_field)[0])

  protocol    = each.value.protocol
  cidr_blocks = each.value.source_type == "cidr" ? [each.value.source] : null
  source_security_group_id = each.value.source_type == "sg" ? each.value.source : null
  prefix_list_ids = each.value.source_type == "prefix" ? [each.value.source] : null

  security_group_id = aws_security_group.this.id
  description      = each.value.description

  depends_on = [aws_security_group.this]
}

# Create egress rules from list format (if provided)
resource "aws_security_group_rule" "egress_list" {
  for_each = local.egress_rules_map
  type     = "egress"

  from_port = tonumber(split("-", each.value.port_field)[0])
  to_port   = tonumber(length(split("-", each.value.port_field)) > 1 ? split("-", each.value.port_field)[1] : split("-", each.value.port_field)[0])

  protocol    = each.value.protocol
  cidr_blocks = each.value.source_type == "cidr" ? [each.value.source] : null
  source_security_group_id = each.value.source_type == "sg" ? each.value.source : null
  prefix_list_ids = each.value.source_type == "prefix" ? [each.value.source] : null

  security_group_id = aws_security_group.this.id
  description      = each.value.description

  depends_on = [aws_security_group.this]
}

# Create individual ingress rules from object format
resource "aws_security_group_rule" "ingress_individual" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }
  type     = "ingress"

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks        = each.value.ipv6_cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids         = each.value.prefix_list_ids
  self                    = each.value.self

  security_group_id = aws_security_group.this.id
  description      = each.value.description

  depends_on = [aws_security_group.this]
}

# Create individual egress rules from object format
resource "aws_security_group_rule" "egress_individual" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }
  type     = "egress"

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  
  cidr_blocks              = each.value.cidr_blocks
  ipv6_cidr_blocks        = each.value.ipv6_cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  prefix_list_ids         = each.value.prefix_list_ids
  self                    = each.value.self

  security_group_id = aws_security_group.this.id
  description      = each.value.description

  depends_on = [aws_security_group.this]
}