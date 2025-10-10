variable "region" {
  type  = string
  
}
variable "account"{
  type = string
  default = "global"
}

variable "install_tools"{
  type = bool
  default = true
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
    "vpc-1d4e687a" = "sg-0fcb234cc5d0621ab" #BG-MAIN-SECTOOLS-SG
    "vpc-7573f90c" = "sg-014df827a6bbd7f79" #BG-GLOBAL-SECTOOLS-SG
    "vpc-00b3ea864e13387ef" = "sg-0c3bdd16645f092cb"
    "vpc-0460835fc8d29e15c" = "sg-0db79006664b22b8f" #BGCN-LAB-SECTOOLS-SG
    "vpc-0b533be2eeff4305c" = "sg-048e09739ac6a6894" #BGEC1-GLOBAL-VSEC-INTERNAL
    "vpc-07ed4ab8a12b27976" = "sg-0efd3ea5aac53da9e" #BG-E1-MAIN-SECTOOLS-SG
  }
}
variable "os_type"{
  type = string
  default = "linux"
}

# Tag variable
variable "RPO" {
  type =  number
}
variable "RTO" {
  type =  number
}
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

# EC2 variables #

variable "instance_name" {
  type  = string
  
}
variable "ami_id" {
  type =  string

}

variable "key_name" {
  type =  string

}

variable "app_instance_type" {
  type =  string

}
variable "root_vol_size" {
  type =  string
  default = "100"
}
variable "ebs_vol_size" {
  type = string
  default = "10"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list
  default = []
}

variable "private_subnets" {
  type = list
  default = []
}
variable "sg_rules_ec2" {
  type        = list(string)
  
  default = []
}

variable "instance_role" {
  type = string
  default = "AmazonSSMRoleForInstancesQuickSetup"
  
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "Optional explicit KMS key ARN to use for root EBS encryption. If set, this ARN is used directly."
}

 
variable "kms_key_alias_name_base" {
  type        = string
  default     = "alias/ebs-key"
  description = "Base alias name used to compose a region-specific alias like 'alias/ebs-key-<region>'. If empty, alias lookup is skipped."
}

