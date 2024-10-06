variable "env" {
  description = "Environment for this project"
  type        = string
}

variable "region" {
  description = "region for dev environment"
}

variable "path_to_public_key" {
  description = "Give the path to you public ssh key"
  type        = string
}

variable "instance_settings" {
  description = "ami value for our ubuntu instance"

  type = map(object({
    instance_ami  = string
    instance_type = string
    subnet_name   = string
    public_ip     = bool
  }))
}

