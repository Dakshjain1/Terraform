resource "kubernetes_storage_class" "tf_efs_sc" {
  metadata {
    name = "tf-eks-sc"
  }
  storage_provisioner = "aws-efs/tf-eks-sc"
  reclaim_policy      = "Retain"
}