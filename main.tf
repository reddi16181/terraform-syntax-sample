provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA5LHTS6FXCV476YKK"
  secret_key = "DtVihV9KSfE5DFiD7YY4ZJ7693bQcG45oWVH7qrJ"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "**********For nodejs server requests**************"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.terraform_instance.public_ip
  description = "The public IP address of the web server"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "terraform_instance" {
  ami           = "ami-062df10d14676e201"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  vpc_zone_identifier  = [data.aws_subnets.default.vpc-id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

}
