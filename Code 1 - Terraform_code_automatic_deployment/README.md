# Terraform_code_automatic_deployment

You can find a detailed article on the same here =>

https://medium.com/@daksh.jain00/automated-website-deployment-using-terraform-525f1d3994df?source=friends_link&sk=892851c404e5fa8ccfaede97b9a796a4

## USAGE
```
terraform apply
```

This will deploy the whole infrastructure on AWS consisting of:
1. Security Group
2. EC2 Instance
3. Extra EBS Volume for storage
4. S3 Bucket for static element storage
5. CloudFront to send this S3 Objects to all edge locations
6. Then magically load it on Chrome

## CAUTION

Few things to keep in mind:
1. Use proper account name
2. Use correct paths according to your Operating System and directories.

To destroy the infrastructure use the command:
```
terraform destroy
```
