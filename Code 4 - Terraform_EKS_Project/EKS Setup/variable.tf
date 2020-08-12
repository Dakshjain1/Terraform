variable "cluster-name" {
  default = "tf_eks_cluster"
  type    = string
}

data "aws_availability_zones" "available" {}