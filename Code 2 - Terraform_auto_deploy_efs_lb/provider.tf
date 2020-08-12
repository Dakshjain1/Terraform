#provider
provider "aws" {
  profile = "root"
  region  = "ap-south-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}
