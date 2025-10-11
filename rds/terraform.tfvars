# Common variables #
region    = "us-west-2"  ##required

#TAG Variables
it_owner = "Imran Bawany"  ##required
BPO = "Imran Bawany" ##required
compliance = "Non-GxP" ##required
application = "Harness" ##required
environment = "D" ##required
department = "GTS - Infrastructure & Operations" ##required

# RDS variables #
vpc_id = "vpc-00b3ea864e13387ef"  #bgne-test-vpc
db_name = "bgus-harness-db-d"
db_storage = 100
db_engine = "mysql"
db_engine_version = "8"
db_engine_minorVersion = "0.42"
db_instance_type = "db.m5.large"#"db.t3.2xlarge"
db_username = "mysql_admin"
db_password = "Test#12092025"

#Subnet Group Variable
subnet_id = ["subnet-00dbe5995075104cb","subnet-01a9a138e30e33f7c"]


sg_rules_rds = [
  "3306,tcp,10.8.126.221/32,AWS Workspace Vaibhav to RDS instances", 
  
]