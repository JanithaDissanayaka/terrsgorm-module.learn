output "ec2_public_ip" {
    value =module.myapp-server.instance.public_ip /*module ->module name->output name of the modules webserver output.tf->resource we need */
}