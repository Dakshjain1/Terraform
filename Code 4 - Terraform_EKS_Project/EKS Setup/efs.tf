# Security Group
# EFS and Resources 

resource "aws_security_group" "tf-efs-sg" {
  name        = "tf-efs-sg"
  description = "Communication to EFS"
  vpc_id      = aws_vpc.tf_eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-efs-sg"
  }
}

resource "aws_efs_file_system" "tf-efs-fs" {
  creation_token = "my-efs-file-system-1"
  tags = {
    Name = "my_efs_fs"
  }
}

resource "aws_efs_mount_target" "tf_efs_mnt_target" {
  count = length(data.aws_availability_zones.available.names)
  file_system_id = aws_efs_file_system.tf-efs-fs.id
  subnet_id      = aws_subnet.tf_eks_subnet.*.id[count.index]
  security_groups = [aws_security_group.tf-efs-sg.id]
}

resource "aws_efs_access_point" "tf_efs_access_pt" {
  file_system_id = aws_efs_file_system.tf-efs-fs.id
}