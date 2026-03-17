resource "google_compute_global_address" "private_service_access" {
  project = var.host_project_id
  name    = "${var.vpc_name}-psa-range"
  network = google_compute_network.main.id

  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"

  prefix_length = 16
  address       = "10.100.0.0"
}

resource "google_service_networking_connection" "private_service_access" {
  network = google_compute_network.main.id
  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [google_compute_global_address.private_service_access.name]
}