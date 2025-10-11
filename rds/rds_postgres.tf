


resource "aws_db_instance" "postgres_instance" {
  count = var.db_engine == "postgres" ? 1 : 0
  identifier              = var.db_name
  allocated_storage       = var.db_storage
  storage_type            = "gp3"
  storage_encrypted       = true
  kms_key_id              = data.aws_kms_alias.rds.target_key_arn
  engine                  = var.db_engine
  engine_version          = "${var.db_engine_version}.${var.db_engine_minorVersion}"
# major_engine_version    = "10.0"
  instance_class          = var.db_instance_type
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  skip_final_snapshot = true
  multi_az = true  ##Custom for thi CR only
# snapshot_identifier     = "bgcn-moveit-db-d-snap-dec23"
# final_snapshot_identifier = "bgcn-moveit-db-d-snap-dec23"
  parameter_group_name =  aws_db_parameter_group.postgres_parameter_group[0].name
  option_group_name       = aws_db_option_group.postgres_option_group[0].name
  vpc_security_group_ids  = [aws_security_group.sg.id]
  db_subnet_group_name    = aws_db_subnet_group.postgres_subnet_group[0].name
  copy_tags_to_snapshot   = true
  tags = merge({ Name = lower("${var.db_name}")},local.common_tags)
  depends_on = [
      aws_security_group.sg,
      aws_db_subnet_group.postgres_subnet_group,
      aws_db_parameter_group.postgres_parameter_group
      ]
        
}


resource "aws_db_subnet_group" "postgres_subnet_group" {
  count = var.db_engine == "postgres" ? 1 : 0
  name       = var.db_name
  subnet_ids = var.subnet_id
  tags = merge({ Name = lower("${var.db_name}")},local.common_tags)
}

resource "aws_db_parameter_group" "postgres_parameter_group" {
  count = var.db_engine == "postgres" ? 1 : 0
  name   = var.db_name
  family = "${var.db_engine}${var.db_engine_version}"
  tags = merge({ Name = lower("${var.db_name}")},local.common_tags)
  
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
  
}

resource "aws_db_option_group" "postgres_option_group" {
  count = var.db_engine == "postgres" ? 1 : 0
  name                     = "${var.db_name}"
  option_group_description = "Option Group for ${var.db_name}"
  engine_name              = "${var.db_engine}"
  major_engine_version     = "${var.db_engine_version}"
}