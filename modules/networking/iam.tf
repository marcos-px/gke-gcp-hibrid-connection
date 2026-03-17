data "google_project" "service" {
  project_id = var.service_project_id
}

resource "google_compute_subnetwork_iam_member" "gke_service_agend" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = google_compute_subnetwork.gke_nodes.name
  role       = "roles/compute.networkUser"

  member = "serviceAccount:service-${data.google_project.service.number}@container-engine-robot.iam.gserviceaccount.com"

}

resource "google_compute_subnetwork_iam_member" "google_apis_agent" {
  project    = var.host_project_id
  region     = var.region
  subnetwork = google_compute_subnetwork.gke_nodes.name
  role       = "roles/compute.networkUser"

  member = "serviceAccount:${data.google_project.service.number}@cloudservices.gserviceaccount.com"
}

