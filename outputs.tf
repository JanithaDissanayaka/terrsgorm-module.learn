output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image
  
}

output "ec2_public_ip" {
    value = aws_instance.myapp-image.public_ip
}