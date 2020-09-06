# Kubernetes Provider
provider "kubernetes" {}

# AWS Provider
provider "aws" {
  profile = "root"
  region  = "ap-south-1"
}

# VPC data soruce
data "aws_vpc" "def_vpc" {
  default = true
}

# Subnet data source
data "aws_subnet_ids" "vpc_sub" {
  vpc_id = data.aws_vpc.def_vpc.id
}