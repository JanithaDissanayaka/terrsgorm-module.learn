provider "aws" {
    region = "ap-south-1"
}

variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable available_zone {}
variable env_prefix {}
variable my_ip {}
variable "instance_type" {}
variable "public_key" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks

    tags = {
      Name: "${var.env_prefix}-vpc"
    }
  
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.available_zone

    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
  
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name="${var.env_prefix}-igw"
  }
  
}

/*resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route{
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name="${var.env_prefix}-rtb"
  }

}*/

/*resource "aws_route_table_association" "art-subnet" {
   subnet_id = aws_subnet.myapp-subnet-1.id
   route_table_id = aws_route_table.myapp-route-table.id

}*/

resource "aws_default_route_table" "default-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route{
    cidr_block="0.0.0.0/0"
    gateway_id=aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name="${var.env_prefix}-main-rtb"
  }
  
}

/*

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.myapp-vpc.id

  ingress{
    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks = [var.my_ip]
  }
  
  ingress{
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  
} */

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress{
    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks = [var.my_ip]
  }
  
  ingress{
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
     Name="${var.env_prefix}-default-sg"
  }
  
}

data "aws_ami" "latest-amazon-linux-image"{
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-x86-64-gp2" ]
  }

  filter {
    
    name = "virtulization-type"
    values = [ "hvm" ]
  }   
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image
  
}

resource "aws_key_pair" "ssh" {
  key_name = "server_key"
  public_key = file(var.public_key)
  
}

resource "aws_instance" "myapp-image" {
  ami= data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id =aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids =[aws_default_security_group.default-sg.id]
  availability_zone = var.available_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh.key_name

  tags={
    name="${var.env_prefix}-ec2"
  }
}
