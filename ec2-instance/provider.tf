provider "aws" {
  region = var.region  
  default_tags {
    tags = local.resource_tags
  }
}
