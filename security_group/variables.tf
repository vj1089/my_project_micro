# Variables for Security Group Module

# Basic Security Group Configuration
variable "name" {
  description = "Name of the security group. If provided, takes precedence over name_prefix"
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Name prefix for the security group. A random suffix will be added"
  type        = string
  default     = ""
}

variable "description" {
  description = "Description for the security group"
  type        = string
  default     = "Terraform managed security group"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "create_default_egress" {
  description = "Whether to create default egress rule allowing all outbound traffic"
  type        = bool
  default     = true
}

# List-based rules (CSV format compatible with existing modules)
variable "ingress_rules_list" {
  description = "List of ingress rules in CSV format: 'port-or-range,protocol,source,description'"
  type        = list(string)
  default     = []
}

variable "egress_rules_list" {
  description = "List of egress rules in CSV format: 'port-or-range,protocol,source,description'"
  type        = list(string)
  default     = []
}

# Object-based rules (more flexible and explicit)
variable "ingress_rules" {
  description = "List of ingress rules as objects"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks        = optional(list(string))
    source_security_group_id = optional(string)
    prefix_list_ids         = optional(list(string))
    self                    = optional(bool)
    description             = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules as objects"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string))
    ipv6_cidr_blocks        = optional(list(string))
    source_security_group_id = optional(string)
    prefix_list_ids         = optional(list(string))
    self                    = optional(bool)
    description             = optional(string)
  }))
  default = []
}

# Tagging Variables (following existing module patterns)
variable "application" {
  description = "Application name for tagging"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment (e.g., dev, prod, staging)"
  type        = string
  default     = ""
}

variable "compliance" {
  description = "Compliance requirement"
  type        = string
  default     = ""
}

variable "it_owner" {
  description = "IT Owner for tagging"
  type        = string
  default     = ""
}

variable "BPO" {
  description = "Business Process Owner"
  type        = string
  default     = ""
}

variable "department" {
  description = "Department responsible for the resource"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to apply to the security group"
  type        = map(string)
  default     = {}
}