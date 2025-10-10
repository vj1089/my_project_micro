
### Terraform resource  block to create EC2 Instance

data "aws_region" "current" {}
// Attempt to resolve a KMS key by alias constructed from kms_key_alias_name_base and region.
data "aws_kms_key" "by_alias" {
  count = length(trimspace(var.kms_key_alias_name_base)) > 0 ? 1 : 0
  key_id = try(data.aws_kms_alias.by_name[0].target_key_id, null)
}

data "aws_kms_alias" "by_name" {
  count = length(trimspace(var.kms_key_alias_name_base)) > 0 ? 1 : 0
  name  = length(trimspace(var.kms_key_alias_name_base)) > 0 ? format("%s-%s", var.kms_key_alias_name_base, coalescelist([data.aws_region.current.name, var.region])[0]) : null
}
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
        kms_key_id = (
          length(trimspace(var.kms_key_arn)) > 0 ? var.kms_key_arn :
          (length(data.aws_kms_key.by_alias) > 0 && data.aws_kms_key.by_alias[0].arn != "" ? data.aws_kms_key.by_alias[0].arn : null)
        )
      }
   
  
  tags = merge({ Name = "${var.instance_name}"},local.common_tags)
}
