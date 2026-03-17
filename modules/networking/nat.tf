resource "google_compute_router_nat" "main" {
  project = var.host_project_id
  name    = "${var.vpc_name}-nat"
  router  = google_compute_router.main.name
  region  = var.region

  nat_ip_allocate_option = "AUTO ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke_nodes.id
    source_ip_ranges_to_nat = ["PRIMARY_ID_RANGE"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  min_ports_per_vm = 64

  enable_dynamic_port_allocation = true

}