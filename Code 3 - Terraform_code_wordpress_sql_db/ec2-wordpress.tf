# security group - 80, 22, ping - public subnet 1a
# ec2 - WP
# key


# security group for wordpress
resource "aws_security_group" "tf_wp_sg" {

  name        = "tf_wp_sg"
  description = "wordpress inbound"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "ping"
  #   from_port   = -1
  #   to_port     = -1
  #   protocol    = "icmp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf-wp-sg"
  }
}

#ec2 instance launch

resource "aws_instance" "wordpress" {

  ami           = "ami-0732b62d310b80e97"  
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub_subnet1.id
  security_groups = [aws_security_group.tf_wp_sg.id]
  key_name = "key1"
  tags = {
    Name = "wordpress"
  }
}
resource "null_resource" "wp-sql-connection" {
  depends_on = [
    aws_instance.mysql
  ]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/6. HYBRID CLOUD/key1.pem")
    host     = aws_instance.wordpress.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su <<END",
      "yum install docker httpd -y",
      "systemctl enable docker",
      "systemctl start docker",
      "docker pull wordpress:5.1.1-php7.3-apache",
      "sleep 30",
      "docker run -dit  -e WORDPRESS_DB_HOST=${aws_instance.mysql.private_ip} -e WORDPRESS_DB_USER=wpuser -e WORDPRESS_DB_PASSWORD=wppass -e WORDPRESS_DB_NAME=wpdb -p 80:80 wordpress:5.1.1-php7.3-apache",
      "END",
    ]
  }
  
}

resource "null_resource" "openwordpress"  {
depends_on = [
    null_resource.wp-sql-connection
  ]
	provisioner "local-exec" {
	    command = "start chrome  http://${aws_instance.wordpress.public_ip}/"
  	}
}