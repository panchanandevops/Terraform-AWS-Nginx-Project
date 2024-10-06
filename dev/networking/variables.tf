variable "env" {
  description = "Environment for this project"
  type        = string
}

variable "region" {
  description = "region for dev environment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "cidr_block for vpc"

  type = string
}

variable "subnet_settings" {
  description = "subnet details"
  type = map(object({
    public_ip         = bool
    cidr_block        = string
    availability_zone = string
  }))
}

variable "sg_settings" {
  type = map(object({
    type        = string
    description = string
    port        = number
    protocol    = string
  }))
  default = {
    ssh_ingress = {
      type        = "ingress"
      description = "Allows SSH access"
      port        = 22
      protocol    = "tcp"
    },
    http_ingress = {
      type        = "ingress"
      description = "Allows HTTP traffic"
      port        = 80
      protocol    = "tcp"
    },
    https_ingress = {
      type        = "ingress"
      description = "Allows HTTPS traffic"
      port        = 443
      protocol    = "tcp"
    },
    all_egress = {
      type        = "egress"
      description = "Allows all outbound traffic"
      port        = 0
      protocol    = "-1"
    }
  }
}
