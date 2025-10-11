

resource "aws_db_instance" "db_instance" {
        identifier              = var.db_name
        allocated_storage       = var.db_storage
        storage_type            = "gp3"
        storage_encrypted       = true
        kms_key_id              = "arn:aws-cn:kms:cn-north-1:256848935116:key/a7ea7c58-0f1c-4f44-96c8-47da99b82016"#"arn:aws:kms:eu-central-1:436207872885:key/b97f2544-6123-4312-bfb1-3b4b0be44310"#"arn:aws-cn:kms:cn-north-1:256848935116:key/a7ea7c58-0f1c-4f44-96c8-47da99b82016"
        engine                  = var.db_engine
        engine_version          = "${var.db_engine_version}.${var.db_engine_minorVersion}"
      # major_engine_version    = "10.0"
        instance_class          = var.db_instance_type
        username                = var.db_username
        password                = var.db_password
        publicly_accessible     = false
        skip_final_snapshot = true
      # snapshot_identifier     = "bgcn-moveit-db-d-snap-dec23"
      # final_snapshot_identifier = "bgcn-moveit-db-d-snap-dec23"
        parameter_group_name =  aws_db_parameter_group.db_parameter_group.name
        option_group_name       = aws_db_option_group.db_option_group.name
        vpc_security_group_ids  = [aws_security_group.sg.id]
        db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
        copy_tags_to_snapshot   = true
        tags = merge({ Name = lower("${var.db_name}")},local.common_tags)
        depends_on = [
                  aws_security_group.sg,
                  aws_db_subnet_group.db_subnet_group,
                  aws_db_parameter_group.db_parameter_group
                  ]
        
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_name
  subnet_ids = var.subnet_id
  tags = merge({ Name = lower("${var.db_name}")},local.common_tags)
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = var.db_name
  family = "${var.db_engine}${var.db_engine_version}.0"
  tags = merge({ Name = lower("${var.db_name}")},local.common_tags)
  
  #parameter {
  #  name  = "rds.force_ssl"
  #  value = "1"
  #}
  
}

resource "aws_db_option_group" "db_option_group" {
  name                     = "${var.db_name}"
  option_group_description = "Option Group for ${var.db_name}"
  engine_name              = "${var.db_engine}"
  major_engine_version     = "${var.db_engine_version}.0"
}




