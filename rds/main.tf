locals {                                       # <----------------------------------
  common_tags = {
    Application     = var.application
    Environment     = var.environment
    Deployment_type = "Terraform"	
    #Deployment_repo = "/opt/Terraform/Terraform/terraform/${var.application}/${var.db_name}"
    Compliance      = var.compliance    
    BPO             = "${var.BPO}"
    IT_Owner        = "${var.it_owner}"    
    Department = var.department
    Managed_By      = var.managed_by
  }
}
