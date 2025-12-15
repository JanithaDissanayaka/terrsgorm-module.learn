provider "aws" {
    region = "ap-south-1"
}

variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable available_zone {}
variable env_prefix {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks

    tags = {
      Name: "${var.env_prefix}-vpc"
    }
  
}

resource "aws_subnet" "myapp-subnet" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.available_zone

    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
  
}