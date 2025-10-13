variable "region" {
  type  = string
  
}
variable "sectool_sgs" {
#type = "map"
  default = {
    "vpc-01f9a47610dadbe50" = "sg-04d57b0e5ac951638"  # BGCN-GLOBAL-SECTOOLS-SG
    "vpc-0baa015e21e0bd363" = "sg-0707944fd5e232e8e"  # BGCN-Test-Sectools-SG
    "vpc-09652f9d7310ec244" = "sg-079024c89e08c6d68"  # BGCN-MAIN-SECTOOLS-SG
    "vpc-0300a625bf5fe3633" ="sg-046bbd9e54b827e40"
    "vpc-09b5d7504c6bade46" = "sg-0cf34019e936655a8"
    "vpc-05820bb5894ee3b63" = "sg-0505c761fdb9d6af5" #BGCN-DEV-VSEC-INTERNAL
  }
}

# Tag variable

variable "it_owner" {
  type =  string
}
variable "BPO" {
  type =  string
}
variable "compliance" {
  type =  string

}
variable "application" {
  type = string
}

variable "environment" {
    type =  string
}
variable "department" {
    type =  string
}
# Load Balancer Variable
variable "lb_name" {
  type  = string
  
}

variable "lb_subnets" {
  type = list  
}

variable "load_balancer_type" {
  type = string  
}

variable "vpc_id" {
  type = string
}
variable "lb_target_group_port" {
  type = list
  
}
variable "sg_rules_alb" {
  type        = list(string)
  description = "CCMS Rule for TCP"
}
# EC2 variables #

