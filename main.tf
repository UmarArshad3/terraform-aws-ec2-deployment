terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
resource "aws_security_group" "web" {
  name        = "terraform-learning-web-sg"
  description = "Security group for Terraform web server practice"

  ingress {
    description = "SSH from my current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["139.135.32.134/32"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "terraform-learning-web-sg"
    Project = "terraform-learning"
  }
}
output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}
resource "aws_instance" "web" {
  ami                         = "ami-09d835910a77f135c"
  instance_type               = "t3.micro"
  subnet_id                   = "subnet-0cdc0be2ca7f3c983"
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = "terraform-learning-key"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "terraform-learning-web"
    Project = "terraform-learning"
  }
}
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 address of the web server"
  value       = aws_instance.web.public_ip
}
