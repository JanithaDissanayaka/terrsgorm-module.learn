provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks

    tags = {
      Name: "${var.env_prefix}-vpc"
    }
  
}
module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_blocks=var.subnet_cidr_blocks
  available_zone=var.available_zone
  env_prefix=var.env_prefix
  vpc_id=aws_vpc.myapp-vpc.id
  default_route_table_id=aws_vpc.myapp-vpc.default_route_table_id


  
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id =aws_vpc.myapp-vpc.id
  my_ip=var.my_ip
  env_prefix=var.env_prefix
  public_key=var.public_key
  instance_type=var.instance_type
  subnet_id=module.myapp-subnet.subnet.id/*module then name after output name*/
  available_zone=var.available_zone

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


