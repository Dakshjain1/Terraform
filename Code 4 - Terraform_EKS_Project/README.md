# EKS-Project

1. First go inside the folder "EKS Setup" and run the commands:
```
terraform init
terraform apply
```

2. Then go inside the folder "EFS Setup" and run the commands:
```
terraform init
terraform apply
```

3. Then go inside the folder "Prometheus Setup" and run the commands:
```
terraform init
terraform apply
```

4. Next remain in the same folder and run the command:
```
kubectl apply -f kube-state-metrics-configs/
```

5. Then follow the article to setup Grafana using Helm.

This will provision your complete setup quickly and monitoring nodes will be quick.

This is the link to the detailed article: 
https://medium.com/@daksh.jain00/provisioning-monitoring-eks-using-terraform-helm-kubernetes-efs-351cd1e927b5
