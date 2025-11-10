# Local values for Security Group Module

# Tags to apply to resources (following existing module pattern)
locals {
  resource_tags = {
    Application     = var.application
    Environment     = var.environment
    Deployment_type = "Terraform"
    Deployment_repo = path.cwd
    Compliance      = var.compliance
    IT_Owner        = var.it_owner
    BPO             = var.BPO
    Department      = var.department
  }
}

# Parse CSV-style ingress rules list into structured format
locals {
  # Pre-parse the CSV-style ingress rules list into lists of fields
  ingress_rules_parsed = [for r in var.ingress_rules_list : split(",", r)]
  
  # Map of parsed ingress rules keyed by index (string) to make for_each selections easy
  # Normalize each parsed rule into an object with trimmed fields
  ingress_rules_map = {
    for idx, parts in local.ingress_rules_parsed : tostring(idx) => {
      port_field   = trimspace(parts[0])
      protocol     = trimspace(parts[1])
      source       = length(parts) > 2 ? trimspace(parts[2]) : ""
      description  = length(parts) > 3 ? trimspace(parts[3]) : ""
      source_type  = length(parts) > 2 ? (
        startswith(trimspace(parts[2]), "sg-") ? "sg" : (
          startswith(trimspace(parts[2]), "pl-") ? "prefix" : "cidr"
        )
      ) : "cidr"
    }
  }
}

# Parse CSV-style egress rules list into structured format
locals {
  # Pre-parse the CSV-style egress rules list into lists of fields
  egress_rules_parsed = [for r in var.egress_rules_list : split(",", r)]
  
  # Map of parsed egress rules keyed by index (string) to make for_each selections easy
  # Normalize each parsed rule into an object with trimmed fields
  egress_rules_map = {
    for idx, parts in local.egress_rules_parsed : tostring(idx) => {
      port_field   = trimspace(parts[0])
      protocol     = trimspace(parts[1])
      source       = length(parts) > 2 ? trimspace(parts[2]) : ""
      description  = length(parts) > 3 ? trimspace(parts[3]) : ""
      source_type  = length(parts) > 2 ? (
        startswith(trimspace(parts[2]), "sg-") ? "sg" : (
          startswith(trimspace(parts[2]), "pl-") ? "prefix" : "cidr"
        )
      ) : "cidr"
    }
  }
}