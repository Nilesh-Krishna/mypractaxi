provider "aws" {
  region = "us-east-1" # Change to your preferred region
}
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Key Pair (Assuming you have an existing key)
variable "key_name" {
  default = "practaxi" # Replace with your key pair name
}

# AMI and Instance Type
variable "ami_id" {
  default = "ami-0c398cb65a93047f2" # Amazon Linux 2 AMI (update for your region)
}

variable "instance_type" {
  default = "t2.micro"
}

# Security Group for Jenkins & Ansible
resource "aws_security_group" "jenkins_ansible_sg" {
  name        = "jenkins-ansible-sg"
  description = "Allow traffic between Jenkins master, slave, and Ansible"

  ingress {
    description = "Allow all traffic from within SG"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.jenkins_ansible_sg.name]

  tags = {
    Name = "jenkins-master"
  }
}

# Jenkins Slave
resource "aws_instance" "jenkins_slave" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.jenkins_ansible_sg.name]

  tags = {
    Name = "jenkins-slave"
  }
}

# Ansible Server
resource "aws_instance" "ansible_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.jenkins_ansible_sg.name]

  tags = {
    Name = "ansible"
  }
}

output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_slave_ip" {
  value = aws_instance.jenkins_slave.public_ip
}

output "ansible_server_ip" {
  value = aws_instance.ansible_server.public_ip
}

module "sgs" {
  source = "../sg_eks"
  vpc_id = data.aws_vpc.default.id
}

# EKS Cluster Module
module "eks" {
  source     = "../eks"
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
  sg_ids     = module.sgs.security_group_public
}


output "eks_cluster_endpoint" {
  value = module.eks.endpoint
}