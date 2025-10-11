provider "aws" {
  region = var.region
  profile = "bgcn" 
  shared_credentials_files = ["/root/.aws/credentials"]
}
