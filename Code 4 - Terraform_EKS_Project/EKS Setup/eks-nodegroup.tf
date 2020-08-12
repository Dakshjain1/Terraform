# EKS Worker Nodes Resources
# IAM role allowing Kubernetes actions to access other AWS services
# EKS Node Group to launch worker nodes

resource "aws_iam_role" "tf-node-role" {
  name = "tf_node_iam_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "tf-node-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.tf-node-role.name
}

resource "aws_iam_role_policy_attachment" "tf-node-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.tf-node-role.name
}

resource "aws_iam_role_policy_attachment" "tf-node-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.tf-node-role.name
}

resource "aws_eks_node_group" "tf_node_grp" {
  cluster_name    = aws_eks_cluster.tf_eks_cluster.name
  node_group_name = "monitor_node"
  node_role_arn   = aws_iam_role.tf-node-role.arn
  subnet_ids      = aws_subnet.tf_eks_subnet[*].id
  instance_types  = ["t2.medium"]
  disk_size = 10

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.tf-node-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.tf-node-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.tf-node-role-AmazonEC2ContainerRegistryReadOnly,
  ]
}
