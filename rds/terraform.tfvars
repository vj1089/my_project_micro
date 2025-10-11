# Common variables #
region    = "cn-north-1"

#TAG Variables
it_owner = "Jia Wei"  ##required
BPO = "Jara Lin" ##required
compliance = "Non-GxP" ##required
application = "TD-Wiki" ##required
environment = "D" ##required
department = "Biologics Technical Development" ##required

# RDS variables #
vpc_id = "vpc-01f9a47610dadbe50"  #BGCN-GLOBAL
db_name = "bgcn-tdwiki-db-d"
db_storage = 100
db_engine = "mysql"
db_engine_version = "8"
db_engine_minorVersion = "0.42"
db_instance_type = "db.m5.large"#"db.t3.2xlarge"
db_username = "mysql_admin"
db_password = "TDWiki#12092025"

#Subnet Group Variable
subnet_id = ["subnet-04eb77daa3e6e1484","subnet-04fea098fcf641ae0"]
#ebs_vol_size = "500" #Data Volme Size

sg_rules_rds = [
  "3306,tcp,10.11.18.194/32,AWS EC2 bgcn-tdwiki-dev-dify to RDS instances", 
  
]