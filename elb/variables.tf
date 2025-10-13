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

variable "managed_by" {
  type =  string
  default = "Harness"
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

# Generalized ELB variables for ALB/NLB
variable "lb_internal" {
  type    = bool
  default = true
  description = "Whether the LB is internal (true) or internet-facing (false)"
}

variable "lb_enable_deletion_protection" {
  type    = bool
  default = false
  description = "Enable deletion protection for the LB"
}

variable "lb_target_group_protocol" {
  type    = string
  default = "HTTP"
  description = "Protocol for the target group (HTTP, HTTPS, TCP, etc.)"
}

variable "lb_target_type" {
  type    = string
  default = "instance"
  description = "Target type for the target group (instance, ip, lambda)"
}

variable "lb_health_check_protocol" {
  type    = string
  default = "HTTP"
  description = "Protocol for health check (HTTP, HTTPS, TCP, etc.)"
}

variable "lb_listener_protocol" {
  type    = string
  default = "HTTP"
  description = "Listener protocol (HTTP, HTTPS, TCP, TLS)"
}

variable "lb_listener_ssl_policy" {
  type    = string
  default = null
  description = "SSL policy for HTTPS/TLS listeners (ALB only)"
}

variable "lb_listener_certificate_arn" {
  type    = string
  default = null
  description = "ARN of the SSL certificate for HTTPS/TLS listeners (ALB only)"
}

