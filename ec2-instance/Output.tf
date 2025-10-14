output "EC2_Details" {
    
    value = {
        InstanceID = aws_instance.server.id
        Name = aws_instance.server.tags_all["Name"]
        IP = aws_instance.server.private_ip
        Instance_SG_ID = aws_security_group.sg.id
        Instance_SG_Name = aws_security_group.sg.tags_all["Name"]
        Instance_Tags = aws_instance.server.tags_all
        Instance_SG_Tags = aws_security_group.sg.tags_all
        os_user = local.os_user
        ansible_connection = local.ansible_connection
        # key_status = data.external.check_key_pair.result.exists == "false" ? "New Created" : "Already Exist"
        #test= data.external.check_key_pair.result.exists
    }
}

output "instance_tags" {
    description = "All tags applied to the EC2 instance (tags_all)"
    value       = aws_instance.server.tags_all
}

output "resource_tags" {
    description = "Common resource tag map from locals.resource_tags"
    value       = local.resource_tags
}

output "ec2_tags" {
    description = "EC2-specific tag map (locals.ec2_tags)"
    value       = local.ec2_tags
}