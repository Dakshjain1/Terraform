resource "kubernetes_cluster_role_binding" "tf_efs_role_binding" {
   depends_on = [
    kubernetes_namespace.tf-ns,
  ]
  metadata {
    name = "tf_efs_role_binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "terraform-prom-graf-namespace"
  }
}