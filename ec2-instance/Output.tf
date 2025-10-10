output "EC2_Details" {
    
    value = {
        InstanceID = aws_instance.server.id
        Name = aws_instance.server.tags_all["Name"]
        IP = aws_instance.server.private_ip
        Instance_SG_ID = aws_security_group.sg.id
        Instance_SG_Name = aws_security_group.sg.tags_all["Name"]
        os_user = local.os_user
        ansible_connection = local.ansible_connection
        # key_status = data.external.check_key_pair.result.exists == "false" ? "New Created" : "Already Exist"
        #test= data.external.check_key_pair.result.exists
    }
}