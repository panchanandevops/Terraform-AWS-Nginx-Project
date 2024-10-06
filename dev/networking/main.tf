terraform {

  backend "s3" {
    bucket         = "panchanandevops-tf-state" 
    key            = "dev/networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
  }

}

provider "aws" {
  region = var.region
}

module "networking" {
  source = "github.com/panchanandevops/terraform-aws-networking.git"

  env             = var.env
  vpc_cidr_block  = var.vpc_cidr_block
  subnet_settings = var.subnet_settings
  sg_settings     = var.sg_settings

}
