# kubernetes cluster - application server - testing 1
# wordpress

variable "sql_vpc_id" {}

resource "google_compute_network" "wp_vpc" {
  name                    = "wp-vpc"
  auto_create_subnetworks = false
}

output "wp_vpc_id" {
  value = google_compute_network.wp_vpc.id
}

resource "google_compute_subnetwork" "app_subnet1" {
  name          = "subnet1"
  ip_cidr_range = "192.168.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.wp_vpc.id
  private_ip_google_access = true
}

resource "google_compute_network_peering" "peering1" {
  depends_on = [
    google_compute_network.wp_vpc
  ]
  name         = "peering1"
  network      = google_compute_network.wp_vpc.id
  peer_network = var.sql_vpc_id
}
