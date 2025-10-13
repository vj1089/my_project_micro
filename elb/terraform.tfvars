region    = "us-west-2"

#TAG Variables
it_owner = "Kristina Kinard"  ##required
BPO = "April Song" ##required
 compliance = "Non-GxP" ##required  
 application = "OutSystems" ##required
 environment = "V" ##required
 department = "GTS - GA" ##required

# EC2 variables #


lb_subnets =["subnet-9f5eb2c4","subnet-58fc6c11"]  #BG-MAIN Validation Web Tier - C and BG-MAIN Validation Web Tier - B
load_balancer_type = "application"
vpc_id = "vpc-1d4e687a"  #BGCN-GLOBAL
lb_name = "bgus-global-outs-alb"
lb_target_group_port = ["443"]
sg_rules_alb = [
  "443,tcp,10.8.0.0/24,Allow private IP"  
]