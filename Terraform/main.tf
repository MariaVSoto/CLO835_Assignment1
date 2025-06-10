#----------------------------------------------------------
# CLO 835 - Assignment1
#
# Build EC2 Instances
#
#----------------------------------------------------------

#  Define local tags
locals {
  default_tags = {
    "Owner"   = "MariaVSoto"
    "App"     = "Web"
    "Project" = "CLO835"
  }
  prefix = "Assignment1"
  name_prefix = "Assignment1"
}

#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Data block to retrieve the default VPC id
data "aws_vpc" "default" {
  default = true
}


# Reference subnet provisioned by default
resource "aws_instance" "Web_VM" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  iam_instance_profile        = "LabInstanceProfile"


  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-VM"
    }
  )
}


# Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-sg"
    }
  )
}

# Elastic IP
resource "aws_eip" "static_eip" {
  instance = aws_instance.Web_VM.id
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-eip"
    }
  )
}

# Amazon ECR Container Registry
resource "aws_ecr_repository" "webapp" {
  name = "my-webapp-image"
}

# Amazon ECR Container Registry
resource "aws_ecr_repository" "mysql" {
  name = "my-mysql-image"
}