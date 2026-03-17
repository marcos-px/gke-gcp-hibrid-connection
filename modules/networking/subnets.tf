resource "google_compute_subnetwork" "gke_nodes" {
  project = var.host_project_id
  name    = "${var.vpc_name}-nodes"
  region  = var.region
  network = google_compute_network.main.id

  ip_cidr_range = var.nodes_cidr

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}