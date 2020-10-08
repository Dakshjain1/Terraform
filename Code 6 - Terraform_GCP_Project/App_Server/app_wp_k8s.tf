variable "uname" {}
variable "pass" {}
variable "pubip" {}
variable "dbname" {}

data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  depends_on = [
    google_container_cluster.wp_gke
  ]
  name     = "wp-gke-cluster"
  location = "us-central1-c"
}

provider "kubernetes" {
  load_config_file = true

  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate,
  )
}

resource "google_compute_address" "static_ip" {
  name = "static-ip-address"
  region = "us-central1"
  project = "prod-56-proj-987"
}

output "static_ip_wp" {
  value = google_compute_address.static_ip.address
}

#deployment
resource "kubernetes_deployment" "wp_deploy" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
      replicas = 1
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
            value = var.pubip
            }
          env {
            name = "WORDPRESS_DB_DATABASE"
            value = var.dbname
            }
          env {
            name = "WORDPRESS_DB_USER"
            value = var.uname
            }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value = var.pass
          }
          port {
        container_port = 80
          }
        }
      }
    }
  }
}

# service 
resource "kubernetes_service" "wp_service" {
  metadata {
    name = "wp-service"
   
  }
  spec {
    load_balancer_ip = google_compute_address.static_ip.address
    selector = {
      app = "wordpress"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  
  }
}

# output "ip" {
#     value = kubernetes_service.wp_service.load_balancer_ingress.0.ip
# }