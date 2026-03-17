resource "google_compute_network" "main" {
  project = var.host_project_id
  name    = var.vpc_name

  auto_create_subnetworks = false

  routing_mode = "GLOBAL"
}