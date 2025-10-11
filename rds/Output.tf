output "RDS_Details" {    
    value = {
        rds_instance_id = aws_db_instance.db_instance.id
        name = aws_db_instance.db_instance.tags_all["Name"]
        private_ip = aws_db_instance.db_instance.address
        instance_sg_id = aws_security_group.sg.id
        instance_sg_name = aws_security_group.sg.tags_all["Name"]
        db_subnetgroup_id = aws_db_subnet_group.db_subnet_group.id
        db_subnetgroup_name = aws_db_subnet_group.db_subnet_group.name
        db_parametergroup_id = aws_db_parameter_group.db_parameter_group.id
        db_parametergroup_name = aws_db_parameter_group.db_parameter_group.name
    }
}