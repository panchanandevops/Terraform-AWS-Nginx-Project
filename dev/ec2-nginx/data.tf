data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "panchanandevops-tf-state"
    key    = "dev/networking/terraform.tfstate"
    region = "us-east-1"
  }
}
