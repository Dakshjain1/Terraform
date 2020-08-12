# securitygroup
resource "aws_security_group" "tf_efs_sg" {
  name        = "tf_efs_sg"
  description = "Communication-efs"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf-task2-sg"
  }
}

# create efs
resource "aws_efs_file_system" "tf_efs" {
  creation_token = "tf-EFS-task2"
  tags = {
    Name = "awsEFS"
  }
}

# mount efs
resource "aws_efs_mount_target" "tf_mount" {
  depends_on = [
    aws_efs_file_system.tf_efs,
    aws_subnet.tf_subnet,
    aws_security_group.tf_efs_sg
  ]
  count = length(data.aws_availability_zones.available.names)
  file_system_id = aws_efs_file_system.tf_efs.id
  subnet_id      = aws_subnet.tf_subnet[count.index].id
  security_groups = [aws_security_group.tf_efs_sg.id]
}

# access point efs
resource "aws_efs_access_point" "efs_access" {
 depends_on = [
    aws_efs_file_system.tf_efs,
  ]
  file_system_id = aws_efs_file_system.tf_efs.id
}