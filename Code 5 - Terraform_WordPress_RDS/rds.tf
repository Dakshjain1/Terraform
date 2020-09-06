# subnet group for DB
resource "aws_db_subnet_group" "sub_ids" {
  name       = "main"
  subnet_ids = data.aws_subnet_ids.vpc_sub.ids

  tags = {
    Name = "DB subnet group"
  }
}

# Security Group for DB
resource "aws_security_group" "allow_data_in_db" {
  name        = "allow_db"
  description = "Allow WP to put data in DB"
  vpc_id      = data.aws_vpc.def_vpc.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
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
    Name = "allow_wp_in_db"
  }
}

# DB Instances
resource "aws_db_instance" "rds_wp" {
  engine                 = "mysql"
  engine_version         = "5.7"
  identifier             = "wordpress-db"
  username               = "admin"
  password               = "admin1234%^"
  instance_class         = "db.t2.micro"
  storage_type           = "gp2"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.sub_ids.id
  vpc_security_group_ids = [aws_security_group.allow_data_in_db.id]
  publicly_accessible    = true
  name                   = "wpdb"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}