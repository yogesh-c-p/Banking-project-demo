terraform {
 required_providers {
 aws = {
 source = "hashicorp/aws"
 version = "~> 4.0"
 }
 }
}

# Configure the AWS Provider
provider "aws" {
}


# Create a VPC
resource "aws_vpc" "vpc" {
 cidr_block = "10.0.0.0/16"
 instance_tenancy = "default"
 enable_dns_hostnames = true
 assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "TerraformVPC"
  }
}

#Create a Gateway
resource "aws_internet_gateway" "internet-gateway" {
 vpc_id = aws_vpc.vpc.id
 tags = {
  Name = "TerraformIGW"
 }
}

# Setting up the routing table
resource "aws_route_table" "routetable" {
 vpc_id = aws_vpc.vpc.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.internet-gateway.id
 }
 tags = {
 Name = "Terraformroutetable"
 }
}


#Create Subnet
resource "aws_subnet" "subnet" {
 vpc_id = aws_vpc.vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone= "us-east-1a"
 map_public_ip_on_launch = true
 tags = {
 Name = "Terraformsubnet"
 }
}


# associate the subnet with the route table
resource "aws_route_table_association" "route-subnet-associate" {
subnet_id = aws_subnet.subnet.id
route_table_id = aws_route_table.routetable.id
}


#Create Security Groups
resource "aws_security_group" "terraform-sg" {
 name = "allow_http"
 description = "enable traffic"
 vpc_id = aws_vpc.vpc.id


 ingress {
   from_port = 443
   to_port = 443
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 80
   to_port = 80
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 22
   to_port = 22
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 8081
   to_port = 8081
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 9090
   to_port = 9090
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 9100
   to_port = 9100
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 3000
   to_port = 3000
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }


 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
 Name = "TerraformSG"
 }
}


locals {
  instance_configure = {
    "Test-Server" = {
      ami       = "ami-053b0d53c279acc90"
      private_ip = "10.0.1.50"
    }
    "Prod-Server" = {
      ami       = "ami-053b0d53c279acc90"
      private_ip = "10.0.1.51"
    }
  }
}


# Creatign Ec2 Instance
resource "aws_instance" "terraform-instance" {
 for_each = local.instance_configure
 ami = each.value.ami # us-east-1
 instance_type = "t2.micro"
 availability_zone = "us-east-1a"
 key_name = "Devops-key"
 private_ip    = each.value.private_ip

 subnet_id = aws_subnet.subnet.id
 vpc_security_group_ids = [aws_security_group.terraform-sg.id]

         tags = {
        Name = each.key
         }
}
