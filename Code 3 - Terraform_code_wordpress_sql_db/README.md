# Terraform_code_wordpress_sql_db

You can find a detailed article on the same here =>

https://medium.com/@daksh.jain00/public-wordpress-and-private-database-on-aws-ec2-3b65c93b756a

## USAGE
```
terraform apply
```
This will deploy the whole infrastructure on AWS consisting of:

* VPC
* Subnets: Public and Private
* Internet Gateway, Route Table, Association
* NAT Gateway, EIP, Route Table, Association
* EC2 Instances: WordPress and MySQL Database
* Then magically load it on Chrome

## CAUTION
Few things to keep in mind:

* Use proper account name
* Use correct paths according to your Operating System and directories.

To destroy the infrastructure use the command:
```
terraform destroy
```
