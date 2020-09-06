#deployment
resource "kubernetes_deployment" "wp_deploy" {
    depends_on = [
    aws_db_instance.rds_wp
    ]
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress-pod"
          env {
            name = "WORDPRESS_DB_HOST"
            value = aws_db_instance.rds_wp.endpoint
            }
          env {
            name = "WORDPRESS_DB_DATABASE"
            value = aws_db_instance.rds_wp.name 
            }
          env {
            name = "WORDPRESS_DB_USER"
            value = aws_db_instance.rds_wp.username
            }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value = aws_db_instance.rds_wp.password
          }
          port {
        container_port = 80
          }
        }
      }
    }
  }
}

#service 
resource "kubernetes_service" "wp_service" {
    depends_on = [
    kubernetes_deployment.wp_deploy,
  ]
  metadata {
    name = "wp-service"
  }
  spec {
    selector = {
      app = "wordpress"
    }
    port {
      port = 80
      target_port = 80
      node_port = 31002
    }

    type = "NodePort"
  }
}
