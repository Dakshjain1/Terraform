# security group - 3306 - private subnet 1b
# security group - (of WP)
# ec2 - MySQL
# key

# security group for wordpress
resource "aws_security_group" "tf_sql_sg" {
  depends_on = [
    aws_route_table_association.tf_ng_assoc
  ]

  name        = "tf_sql_sg"
  description = "mysql inbound"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.tf_wp_sg.id]

  }

  # ingress {
  #   description = "ping"
  #   from_port   = -1
  #   to_port     = -1
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "ssh"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf_sql_sg"
  }
}

#ec2 instance launch

resource "aws_instance" "mysql" {
  depends_on = [
    aws_instance.wordpress
  ]
  ami           = "ami-0732b62d310b80e97"  
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pvt_subnet2.id
  security_groups = [aws_security_group.tf_sql_sg.id]
  key_name = "key1"
  user_data = <<END
  #!/bin/bash
  sudo yum install mariadb-server mysql -y
  sudo systemctl enable mariadb.service
  sudo systemctl start mariadb.service
  mysql -u root <<EOF
  create user 'wpuser'@'${aws_instance.wordpress.private_ip}' identified by 'wppass';
  create database wpdb;
  grant all privileges on wpdb.* to 'wpuser'@'${aws_instance.wordpress.private_ip}';
  exit
  EOF
  END
 
  tags = {
    Name = "sql"
  }
}

