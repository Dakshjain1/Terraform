#ec2 instance launch
resource "aws_instance" "tf_task2_ec2_webserver" {
depends_on = [
    aws_vpc.tf_vpc,
    aws_subnet.tf_subnet,
    aws_efs_file_system.tf_efs,
  ]
  count = 2
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id      = aws_subnet.tf_subnet[count.index].id
  security_groups = [ aws_security_group.tf_efs_sg.id ]
  key_name = "key1"
 
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/key1.pem")
    host      = self.public_ip
  }

provisioner "remote-exec" {
    inline = [
        "sudo su <<END",
        "yum install git php httpd amazon-efs-utils -y",
        "rm -rf /var/www/html/*",
        "/usr/sbin/httpd",
        "efs_id=${aws_efs_file_system.tf_efs.id}",
        "accesspt_id=${aws_efs_access_point.efs_access.id}",
        "mount -t efs $efs_id:/ /var/www/html",
        "echo \"$efs_id /var/www/html efs _netdev,tls,accesspoint=$accesspt_id 0 0\" > /etc/fstab",
        "mount -a",
        "git clone https://github.com/Dakshjain1/php-cloud.git /var/www/html/",
        "END",
    ]
  }
  tags = {
    Name = "tf_task2_ec2_webserver"
  }
}

 # s3 bucket
 resource "aws_s3_bucket" "tf_s3bucket" {
   bucket = "098web1bucket2"
   acl    = "public-read"
   region = "ap-south-1"

   tags = {
     Name = "098web1bucket2"
   }
 }

 # adding object to s3
 resource "aws_s3_bucket_object" "tf_s3_image-upload" {
 depends_on = [
     aws_s3_bucket.tf_s3bucket,
   ]
     bucket  = aws_s3_bucket.tf_s3bucket.bucket
     key     = "concert.jpg"
     source = "C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/Terraform/task2 cc/concert.jpg"
     acl     = "public-read"
 }

 # cloudfront variable
  variable "oid" {
 	type = string
  default = "S3-"
 }

 locals {
   s3_origin_id = "${var.oid}${aws_s3_bucket.tf_s3bucket.id}"
 }

 # cloudfront distribution
 resource "aws_cloudfront_distribution" "tf_s3_distribution" {
   depends_on = [
     aws_s3_bucket_object.tf_s3_image-upload,
   ] 
   origin {
     domain_name = "${aws_s3_bucket.tf_s3bucket.bucket_regional_domain_name}"
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
 }
 resource "null_resource" "cluster" {
   depends_on = [
      aws_cloudfront_distribution.tf_s3_distribution,  
    ]
   count = 2
   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Daksh jain/Desktop/IIEC_VIMAL DAGA/HYBRID CLOUD/key1.pem")
    host     = aws_instance.tf_task2_ec2_webserver[count.index].public_ip
  }
   provisioner "remote-exec" {
     inline = [
         "sudo su <<END",
         "sudo echo \"<img src='http://${aws_cloudfront_distribution.tf_s3_distribution.domain_name}/${aws_s3_bucket_object.tf_s3_image-upload.key}' height='200' width='200' >\"  >> /var/www/html/index.php",
         "END",
     ]
   }
 }