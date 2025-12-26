


resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

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



resource "aws_key_pair" "ssh" {
  key_name = "server_key"
  public_key = file(var.public_key)
  
}

resource "aws_instance" "myapp-image" {
  ami= data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id =var.subnet_id
  vpc_security_group_ids =[aws_default_security_group.default-sg.id]
  availability_zone = var.available_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh.key_namegit 

  user_data = file("entry-script.sh")  /*<- this we can usde but this not usee by terraform this execute by service provider much better use*/

  /* provisioner not recoomended by terraform
  
  connection {
    
      type="ssh"
      host =self.public_ip
      user="ec2-user"
      private_key = file(var.private_key)

    
  }

  provisioner "file" {
    source = "entry-script.sh"

    destination = "/home/ec2-user/entry-script2.sh"
    
  }
  
  provisioner "remote-exec" {

    script = file("entry-script2.sh")
    
  }

  provisioner "local-exec"{
  command="echo ${self.public_ip}>output.txt}"
  }*/

  tags={
    name="${var.env_prefix}-ec2"
  }
}