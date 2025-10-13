locals {                                       # <----------------------------------
  common_tags = {
    Application     = var.application
    Environment     = var.environment
    Deployment_type = "Terraform"	
    Deployment_repo = "${path.cwd}/${var.lb_name}"
    Compliance      = var.compliance    
    BPO             = "${var.BPO}"
    IT_Owner        = "${var.it_owner}"    
    Department      = var.department
#AZ              = var.az
#Patch Group     = var.patchgroup
  }
}
