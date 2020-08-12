#provider

provider "aws" {
  profile = "daksh"
  region  = "ap-south-1"
}


#securitygroup

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-59766a31"

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
}

#ec2 instance launch

resource "aws_instance" "webserver" {
  ami             = "ami-0447a12f28fddb066"
  instance_type   = "t2.micro"
  security_groups = [ "allow_traffic" ]
  key_name = "key1"
 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/key1.pem")
    host        = aws_instance.webserver.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd"
    ]
  }
  tags = {
    Name = "webserver"
  }
}

# create volume
resource "aws_ebs_volume" "web_vol" {
 availability_zone = aws_instance.webserver.availability_zone
 size = 1
 tags = {
   Name = "web_vol"
 }
}

# attach volume

resource "aws_volume_attachment" "web_vol" {

depends_on = [
    aws_ebs_volume.web_vol,
  ]
 device_name  = "/dev/xvdf"
 volume_id    = aws_ebs_volume.web_vol.id
 instance_id  = aws_instance.webserver.id
 force_detach = true

connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/key1.pem")
    host        = aws_instance.webserver.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Dakshjain1/php-cloud.git /var/www/html/"

    ]
  }
}

# s3 bucket

resource "aws_s3_bucket" "s3bucket" {
  bucket = "123mywebbucket321"
  acl    = "public-read"
  region = "ap-south-1"

  tags = {
    Name = "123mywebbucket321"
  }
}

# adding object to s3

resource "aws_s3_bucket_object" "image-upload" {

depends_on = [
    aws_s3_bucket.s3bucket,
  ]
    bucket  = aws_s3_bucket.s3bucket.bucket
    key     = "flower.jpg"
    source  = "C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/Terraform/task1/pic.jpg"
    acl     = "public-read"
}

output "bucketid" {
  value = aws_s3_bucket.s3bucket.bucket
}

# cloud front

variable "oid" {
	type    = string
 	default = "S3-"
}

locals {
  s3_origin_id = "${var.oid}${aws_s3_bucket.s3bucket.id}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
depends_on = [
    aws_s3_bucket_object.image-upload,
  ]
  origin {
    domain_name = "${aws_s3_bucket.s3bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

  enabled             = true
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }


connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/key1.pem")
    host        = aws_instance.webserver.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo su <<END",
      "echo \"<img src='http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.image-upload.key}' height='200' width='200'>\" >> /var/www/html/index.php",
      "END",
    ]
  }
}

resource "null_resource" "openwebsite"  {
depends_on = [
    aws_cloudfront_distribution.s3_distribution, aws_volume_attachment.web_vol
  ]
	provisioner "local-exec" {
	    command = "start chrome  http://${aws_instance.webserver.public_ip}/"
  	}
}

