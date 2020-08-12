# terraform-auto-deploy-efs-lb
This is upgradation to last terraform code.

You can find a detailed article on the same here =>

https://medium.com/@daksh.jain00/automatic-website-deployment-using-terraform-and-amazon-efs-935966c0d18b

## USAGE
```terraform apply```
This will deploy the whole infrastructure on AWS consisting of:

1. VPC
2. Subnets, Route and Route Associations
3. EFS - Elastic File System
4. Security Groups
5. EC2 Instances
6. S3 bucket for storing static data
7. CloudFront to send this S3 Objects to all edge locations
8. AWS Elastic Load Balancer and requirements
6. Then magically load it on Chrome

## CAUTION
Few things to keep in mind:
1. Use proper account name
2. Use correct paths according to your Operating System and directories.

To destroy the infrastructure use the command:
```
terraform destroy
```
