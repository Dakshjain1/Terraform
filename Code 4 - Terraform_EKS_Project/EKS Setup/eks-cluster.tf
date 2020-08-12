# EKS Cluster Resources
# IAM Role to allow EKS service to manage other AWS services
# EC2 Security Group to allow networking traffic with EKS cluster
# EKS Cluster

resource "aws_iam_role" "tf-eks-role" {
  name = "tf_eks_iam_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "tf-eks-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tf-eks-role.name
}

resource "aws_iam_role_policy_attachment" "tf-eks-role-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.tf-eks-role.name
}

resource "aws_security_group" "tf_eks_sg" {
  name        = "tf_eks_sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.tf_eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-eks-sg"
  }
}

resource "aws_security_group_rule" "demo-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.tf_eks_sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "tf_eks_cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.tf-eks-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.tf_eks_sg.id]
    subnet_ids         = aws_subnet.tf_eks_subnet[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.tf-eks-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.tf-eks-role-AmazonEKSServicePolicy,
  ]
}