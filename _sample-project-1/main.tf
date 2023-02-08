/*
# CREDS
Console:  https://.signin.aws.amazon.com/console
User:     
Pass:     

# Use provider or environment variables
# Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables
export AWS_SECRET_ACCESS_KEY=
export AWS_ACCESS_KEY_ID=


# NOTES
resource: create new resources
data: pull data from existing resources
output: output after applying a resource

# FILES
terraform.tfvars: contains variables

# COMMANDS
terraform init
terraform plan
terraform apply
terraform apply -var "subnet_cidr_block=10.0.30.0/24"
terraform apply -auto-approve -var-file terraform-dev.tfvars
terraform destroy
terraform destroy -target aws_subnet.dev-subnet-2
terraform state list
terraform state show aws_vpc.dev-vpc

# GIT
git init
git add .
git commit -m "initial commit"
git remote add origin https://github.com/buraktokman/Terraform.git
git remote add origin git@github.com:buraktokman/terraform
git push -origin master

git status
git branch -M main
*/


# provider "aws" {
#     region = "us-east-1" # or use AWS_DEFAULT_REGION env var
#     access_key = ""      # or use AWS_ACCESS_KEY_ID env var
#     secret_key = ""      # or use AWS_SECRET_ACCESS_KEY env var
# }

# Use environment variables
provider "aws" {}


# ------ VARIABLES -----------
variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
#   default     = "10.1.10.0/24" # (optional)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
}

variable "cidr_blocks" {
  description = "CIDR blocks"
#   type = list(string)
  type = list(object(
    {
      cidr_block = string
      name = string
    }
  ))
}

# Custom env var (use TF_VAR_ prefix)
# export TF_VAR_avail_zone="us-east-1a"
variable "avail_zone" {}

variable "environment" {
  description = "Deployment environment"
}

# ------ IAC -----------------
# Create a VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
# First one is resource type, second one is the name of the resource
resource "aws_vpc" "development-vpc" {
    # cidr_block = "10.1.0.0/16"
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        # Name: "development-vpc"
        Name: var.cidr_blocks[0].name
        environment: "development"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    # cidr_block = "10.1.10.0/24"
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.cidr_blocks[1].name
        # Name: "dev-subnet-1"
    }
}

# Get default VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "existing_vpc" {
    default = true
}

# Create subnet in existing VPC
resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "us-east-1a"
    tags = {
        Name: "dev-subnet-2"
    }
}

output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id
}

