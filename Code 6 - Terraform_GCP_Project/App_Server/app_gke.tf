data "google_project" "prod_project" {}

resource "google_container_cluster" "wp_gke" {
  depends_on = [
    google_compute_network.wp_vpc
  ]
  name     = "wp-gke-cluster"
  location = "us-central1-c"
  initial_node_count       = 1
  remove_default_node_pool = true
  network = google_compute_network.wp_vpc.name
  subnetwork = google_compute_subnetwork.app_subnet1.name
}

resource "google_container_node_pool" "wp_cluster_nodes" {
  name       = "wp-node-pool"
  location   = "us-central1-c"
  cluster    = google_container_cluster.wp_gke.name
  node_count = 1

  node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = 100
    disk_type = "pd-standard"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "null_resource" "update_kubeconfig"  {
depends_on = [
    google_container_node_pool.wp_cluster_nodes
  ]
	provisioner "local-exec" {
        command = <<EOF
     	 gcloud container clusters get-credentials ${google_container_cluster.wp_gke.name} --zone ${google_container_cluster.wp_gke.location} --project ${data.google_project.prod_project.project_id}
       sleep 5
       EOF
    
    interpreter = ["PowerShell", "-Command"]
  	}
}
