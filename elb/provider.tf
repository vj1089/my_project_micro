provider "aws" {
  region = var.region
  profile = "bgus" 
  shared_credentials_files = ["/root/.aws/credentials"]
}
