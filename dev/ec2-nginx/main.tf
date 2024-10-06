terraform {

  backend "s3" {
    bucket         = "panchanandevops-tf-state" 
    key            = "dev/ec2_nginx/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
  }

}

provider "aws" {
  region = var.region
}

module "ec2_nginx" {
  source = "github.com/panchanandevops/terraform-aws-ec2-nginx.git"

  env = var.env
  path_to_public_key = var.path_to_public_key
  instance_settings = var.instance_settings

  public_subnet_ids = data.terraform_remote_state.networking.outputs.public_subnet_ids
  security_group_id = data.terraform_remote_state.networking.outputs.security_group_id

}
