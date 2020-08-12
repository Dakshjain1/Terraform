# create vpc
# create 2 subnet : public & private
# create internet gateway
# create route table
# associate route (0.0.0.0/0)
# eip
# create NAT gateway
# edit default route table
# associate route for NAT (0.0.0.0/0)

#provider
provider "aws" {
  profile = "root"
  region  = "ap-south-1"
}

# vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags= {
     Name = "tf-vpc"
}
}

# public subnet
resource "aws_subnet" "pub_subnet1" {

  vpc_id            = aws_vpc.tf_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block        = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags= {
     Name = "pub-subnet1"
}
}


# internet gateway
resource "aws_internet_gateway" "tf_ig" {

  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf-ig"
  }
}

# IGW route table
 resource "aws_route_table" "tf_ig_route" {

  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_ig.id
  }
  tags = {
    Name = "tf-ig-route"
  }
}

# IGW route association
resource "aws_route_table_association" "tf_ig_assoc" {

  subnet_id      = aws_subnet.pub_subnet1.id
  route_table_id = aws_route_table.tf_ig_route.id
}

# private subnet
resource "aws_subnet" "pvt_subnet2" {

  vpc_id            = aws_vpc.tf_vpc.id
  availability_zone = "ap-south-1b"
  cidr_block        = "192.168.2.0/24"
  map_public_ip_on_launch = false
  tags= {
     Name = "pvt-subnet2"
}
}

# EIP
resource "aws_eip" "tf-eip" {
  tags = {
    "Name" = "vpc-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "tf_ngw" {

  allocation_id = aws_eip.tf-eip.id
  subnet_id     = aws_subnet.pub_subnet1.id
  tags = {
    "Name" = "tf-ng"
  }
}

# NGW Route Table
resource "aws_default_route_table" "tf_ng_route" {
  depends_on = [
    aws_nat_gateway.tf_ngw
  ]
  default_route_table_id = aws_vpc.tf_vpc.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_ngw.id
  }
  tags = {
    Name = "tf-ng-route"
  }
}

# NGW route association
resource "aws_route_table_association" "tf_ng_assoc" {

  subnet_id      = aws_subnet.pvt_subnet2.id
  route_table_id = aws_default_route_table.tf_ng_route.id
}

