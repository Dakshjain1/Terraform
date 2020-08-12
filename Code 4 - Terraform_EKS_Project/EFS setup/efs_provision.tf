resource "kubernetes_deployment" "tf-efs-provisioner" {

  depends_on = [
  kubernetes_storage_class.tf_efs_sc,
  kubernetes_namespace.tf-ns
  ]

  metadata {
    name = "tf-efs-provisioner"
    namespace = "terraform-prom-graf-namespace"
  }

  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        app = "tf-efs"
      }
    }

    template {
      metadata {
        labels = {
          app = "tf-efs"
        }
      }

      spec {
        automount_service_account_token = true
        container {
          image = "quay.io/external_storage/efs-provisioner:v0.1.0"
          name  = "tf-efs-provision"
          env {
            name  = "FILE_SYSTEM_ID"
            value = data.aws_efs_file_system.tf-efs-fs.file_system_id
          }
          env {
            name  = "AWS_REGION"
            value = "ap-south-1"
          }
          env {
            name  = "PROVISIONER_NAME"
            value = kubernetes_storage_class.tf_efs_sc.storage_provisioner
          }
          volume_mount {
            name       = "pv-volume"
            mount_path = "/persistentvolumes"
          }
        }
        volume {
          name = "pv-volume"
          nfs {
            server = data.aws_efs_file_system.tf-efs-fs.dns_name
            path   = "/"
          }
        }
      }
    }
  }
}
