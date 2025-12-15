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

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route{
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name="${var.env_prefix}-rtb"
  }

}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name="${var.env_prefix}-igw"
  }
  
}