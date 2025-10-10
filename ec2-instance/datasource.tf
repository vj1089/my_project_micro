#### Terraform Datasource Block to get details for  AMI
data "aws_ami" "ami_data" {
  
  most_recent      = true
  

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }  
}

