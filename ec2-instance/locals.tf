##### Terraform Local Block to set TAGs for EC2 Instance
locals {                                       # <----------------------------------
  common_tags = {
    Application     = var.application
    Environment     = var.environment
    Deployment_type = "Terraform"	
    Deployment_repo = "${path.cwd}/${var.instance_name}"
    Compliance      = var.compliance
    SentinelOneAgent= ""
    QualysAgent     = ""
    SplunkAgent     = ""
    BPO             = "${var.BPO}"
    IT_Owner        = "${var.it_owner}"
    RPO             = var.RPO
    RTO             = var.RTO
    N2WS_Policy_Code = ""
    Department = var.department
#AZ              = var.az
#Patch Group     = var.patchgroup
  }
}
##### Terraform Local Block to general variable required for creation of  EC2 Instance
locals {
  os_user = strcontains(lower(data.aws_ami.ami_data.description), "amazon linux") || strcontains(lower(data.aws_ami.ami_data.description), "red hat") ? "ec2-user" : (strcontains(lower(data.aws_ami.ami_data.description), "ubuntu") ? "ubuntu" : (strcontains(lower(data.aws_ami.ami_data.description), "debian") ? "admin" : (strcontains(lower(data.aws_ami.ami_data.description), "windows") ? "Administrator" :"root")))  
  account = lower(var.account) == "global" ? "global" : "china"
  delay_sec = lower(var.os_type) == "windows" ? 240 : 300
  #key_exists = try(data.aws_key_pair.pem_key.id, null) != null
  aws_profile = lower(var.account) == "global" ? "bgus" : "bgcn"
}
##### Terraform Local Block to set ansible variable enabling execution fo SEC and Datddog on Ansible server
locals {
  ansible_server_ip = "10.8.33.65"
  ansible_connection = lower(var.os_type) == "windows" ? "${aws_instance.server.private_ip} ansible_user=svc.ansible ansible_password=54OT33R5TxUniFTSHra8$ ansible_connection=winrm ansible_winrm_scheme=http ansible_winrm_server_cert_validation=ignore ansible_winrm_port=5985 ansible_winrm_message_encryption=auto ansible_winrm_transport=ntlm" : "${aws_instance.server.private_ip} ansible_ssh_private_key_file=/home/vjain/pemkeys/${var.key_name}.pem ansible_ssh_user=${local.os_user}"
  #ansible_connection = lower(var.os_type) == "windows" ?  "${aws_instance.server.private_ip} ansible_ssh_user=svc.ansible ansible_password=54OT33R5TxUniFTSHra8$ ansible_connection=winrm ansible_winrm_scheme=http ansible_winrm_server_cert_validation=ignore ansible_winrm_port=5985 ansible_winrm_message_encryption=auto ansible_winrm_transport=ntlm" :  "${aws_instance.server.private_ip} ansible_ssh_private_key_file=/home/vjain/pemkeys/${var.key_name}.pem ansible_ssh_user=${local.os_user} ansible_python_interpreter=/usr/bin/python3"

  ansible_central_pem_path = "/home/vjain/pemkeys/"
  ansible_pem_path = "/opt/Terraform/Terraform/terraform/ansible_pem/ansible.pem.pem"
  ansible_datadog_path = "/home/vjain/ansible/playbook/Datadog/Datadog_Installation"
  ansible_qualys_path = "/home/vjain/ansible/playbook/sectool/qualys"
  ansible_sentinel_path = "/home/vjain/ansible/playbook/sectool/s1"
  ansible_splunk_path = "/home/vjain/ansible/playbook/sectool/splunk-forwarder"
  ansible_cs_path = "/home/vjain/ansible/playbook/sectool/crowdstrike"
}

