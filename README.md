## Terraform AWS EC2 Nginx Project

This Terraform project deploys a VPC, EC2 instance running NGINX, and uses an S3 bucket as the remote backend for storing Terraform state. The project is designed for a **development environment** and follows a modular structure for managing networking, EC2 deployment, and remote state storage.

### Project Structure

```
Terraform-AWS-Nginx-Project
├── dev
│   ├── ec2-nginx
│   │   ├── data.tf                # Retrieves remote state data for networking
│   │   ├── main.tf                # Defines EC2 instance and backend configuration
│   │   ├── outputs.tf             # Outputs public IP of the EC2 instance
│   │   ├── ssh
│   │   │   └── ubuntu_nginx.pub   # Public key for SSH access
│   │   ├── terraform.tfvars       # Variables specific to the environment (dev)
│   │   └── variables.tf           # Variable definitions for EC2 module
│   └── networking
│       ├── main.tf                # Defines VPC, subnets, and security groups
│       ├── outputs.tf             # Outputs VPC and networking details
│       ├── terraform.tfvars       # Environment-specific networking variables
│       └── variables.tf           # Variable definitions for networking module
├── global
│   └── s3-backend
│       ├── backend.tf             # S3 backend and DynamoDB state lock setup
│       ├── terraform.tfstate      # State file (local initially, remote after apply)
│       └── terraform.tfstate.backup # Backup state file
└── README.md                      
```

### Networking Module (`dev/networking`)

This module creates the networking infrastructure for the project, including a VPC, subnets, and security groups. It is designed to provide a secure environment for the EC2 instance running NGINX.

#### Key Components:

- **VPC**: A virtual private cloud with CIDR block `10.0.0.0/16`.
- **Subnets**: Public subnets with `us-east-1a` availability zone.
- **Security Groups**: Configured for SSH (port 22), HTTP (port 80), and HTTPS (port 443) ingress. All outbound traffic is allowed.

#### Code Overview:

- **main.tf**: Defines the VPC, subnets, and security groups. Uses the `terraform-aws-networking` module.
  
- **outputs.tf**: Exports subnet IDs and security group IDs for use by the EC2 module.
  
- **variables.tf**: Contains environment variables, VPC CIDR, and subnet details.

- **terraform.tfvars**: Sets the environment and region, defines subnet and security group settings.

```hcl
env             = "dev"
region          = "us-east-1"
vpc_cidr_block  = "10.0.0.0/16"

subnet_settings = {
  "subnet-1a" = {
    public_ip         = true
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
}

sg_settings = {
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
```

### EC2 Nginx Module (`dev/ec2-nginx`)

This module launches an EC2 instance running Ubuntu and installs NGINX using a simple shell script. It retrieves the networking information from the `networking` module using the remote state stored in an S3 bucket.

#### Key Components:

- **EC2 Instance**: Ubuntu 24.04 instance with NGINX installed.
- **User Data**: A shell script (`nginx-script.sh`) is executed during instance startup to install NGINX and set up a custom index page.

#### Code Overview:

- **data.tf**: Retrieves the networking module's outputs (subnet and security group IDs) from the remote state in S3.
  
- **main.tf**: Defines the EC2 instance configuration, including AMI, instance type, key pair for SSH, and security group association.

- **outputs.tf**: Outputs the public IP of the EC2 instance.

- **variables.tf**: Defines environment variables and instance settings (AMI, instance type, subnet, public IP).

- **terraform.tfvars**: Provides values for the EC2 instance (AMI, instance type, etc.).

```hcl
instance_settings = {
  "ubuntu-24" = {
    instance_ami = "ami-0866a3c8686eaeeba"
    instance_type = "t2.micro"
    subnet_name  = "subnet-1a"
    public_ip = true
  }
}
```

#### NGINX Installation Script (`scripts/nginx-script.sh`)

```bash
#!/bin/bash
sudo apt update -y
sudo apt install -y nginx

# Create index.html with H1 tag in the default NGINX web directory
echo "<h1>Hello From Ubuntu EC2 Instance!!!</h1>" | sudo tee /var/www/html/index.html

# Restart NGINX to apply the changes
sudo systemctl restart nginx
```

### S3 Backend Configuration (`global/s3-backend`)

The project uses an S3 bucket to store Terraform state files, with DynamoDB for state locking. This ensures that multiple users cannot modify the same state at the same time, and state is versioned and encrypted.

#### Key Components:

- **S3 Bucket**: Stores the state file for both the networking and EC2 modules.
- **DynamoDB**: Used to lock the state during deployments, preventing concurrent changes.

#### Code Overview:

- **backend.tf**: Defines the S3 bucket and DynamoDB table for remote state storage.

- **aws_s3_bucket**: Creates the S3 bucket with encryption and versioning enabled.

- **aws_dynamodb_table**: Creates a DynamoDB table for state locking.

```hcl
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket        = "panchanandevops-tf-state"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "terraform_state_lock_table" {
  name         = "terraform-state-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### Conclusion

This project demonstrates how to deploy an EC2 instance running NGINX on AWS using Terraform with a modular structure. The configuration includes networking infrastructure, remote state management via S3, and a custom user data script to set up NGINX. 

### Usage Instructions

1. Clone the repository and navigate to the `dev/ec2-nginx` directory.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the changes:
   ```bash
   terraform apply
   ```
5. Access the public IP of the EC2 instance via the output:
   ```bash
   terraform output ubuntu_instance_public_ip
   ```

You should now see a "Hello From Ubuntu EC2 Instance!!!" message when you visit the public IP in a browser.