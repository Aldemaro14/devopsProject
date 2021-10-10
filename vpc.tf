terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}

# Create VPC
resource "aws_vpc" "testvpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
      Name = "testvpc"
  }
}
# Create subnets in the custom vpc
resource "aws_subnet" "public_vpc1" {
  vpc_id     = aws_vpc.testvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-1a"

  tags = {
    Name = "public_vpc1"
  }
}

resource "aws_subnet" "public_vpc2" {
  vpc_id     = aws_vpc.testvpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-1b"

  tags = {
    Name = "public_vpc2"
  }
}

resource "aws_subnet" "private_vpc1" {
  vpc_id     = aws_vpc.testvpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-west-1a"

  tags = {
    Name = "private_vpc1"
  }
}

# Define Interget Gateway

resource "aws_internet_gateway" "vpc_gw" {
  vpc_id = aws_vpc.testvpc.id

  tags = {
    Name = "vpc-ig"
  }
}

# Define Routing Table for teh custom VPC

resource "aws_route_table" "vpc_r" {
  vpc_id = aws_vpc.testvpc.id

  route {
      cidr_block = "0.0.0.0/24"
      gateway_id = aws_internet_gateway.vpc_gw.id
    }

  tags = {
    Name = "vpc-public-r"
  }
}

# Add Route Table Association

resource "aws_route_table_association" "vpc_public_1_a" {
  subnet_id      = aws_subnet.public_vpc1.id
  route_table_id = aws_route_table.vpc_r.id
}

resource "aws_route_table_association" "vpc_public_2_a" {
  subnet_id      = aws_subnet.public_vpc2.id
  route_table_id = aws_route_table.vpc_r.id
}

