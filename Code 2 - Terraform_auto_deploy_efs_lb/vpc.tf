# create vpc
# create subnet
# create internet gateway
# create route table
# associate route (0.0.0.0/0)

# vpc
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags= {
     Name = "task2-tf-vpc"
}
}

# subnet
resource "aws_subnet" "tf_subnet" {
  depends_on = [
    aws_vpc.tf_vpc
  ]
  count = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  tags= {
     Name = "task2-tf-subnet"
}
}

# internet gateway
resource "aws_internet_gateway" "tf_ig" {
  depends_on = [
    aws_vpc.tf_vpc
  ]
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "task2-tf-ig"
  }
}

# route table
 resource "aws_route_table" "tf_route" {
  depends_on = [
    aws_vpc.tf_vpc
  ]
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_ig.id
  }
  tags = {
    Name = "task2-tf-route"
  }
}

# route association
resource "aws_route_table_association" "tf_assoc" {
  depends_on = [
    aws_subnet.tf_subnet
  ]
  count = length(data.aws_availability_zones.available.names)-1
  subnet_id      = aws_subnet.tf_subnet[count.index].id
  route_table_id = aws_route_table.tf_route.id
}
