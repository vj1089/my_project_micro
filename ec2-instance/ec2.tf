
### Terraform resource  block to create EC2 Instance
resource "aws_instance" "server" {
  ami = var.ami_id
  instance_type = "${var.app_instance_type}"
  key_name = var.key_name 
  iam_instance_profile = "${var.instance_role}"
  vpc_security_group_ids = [ aws_security_group.sg.id,var.sectool_sgs[var.vpc_id] ]
  subnet_id = var.private_subnets[0]
  user_data = lower(var.os_type) == "linux"  ? file("${path.module}/userdata/init_linux") : file("${path.module}/userdata/init_win")
  metadata_options {
    instance_metadata_tags = "enabled"
  }
 
  root_block_device {
        volume_size           = var.root_vol_size
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = false
        kms_key_id = "arn:aws-cn:kms:cn-north-1:256848935116:key/720b0f16-59d5-444b-a153-ecadd790deb8"#"arn:aws:kms:us-west-2:436207872885:key/4f247c31-7bd3-4574-8bb8-796045cd1133"
      }
   
  
  tags = merge({ Name = "${var.instance_name}"},local.common_tags)
}
