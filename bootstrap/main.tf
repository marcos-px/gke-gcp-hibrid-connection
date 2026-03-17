provider "google" {
  region = var.region
}

provider "google-beta" {
  region = var.region
}

resource "google_project" "host" {
  name            = var.project_host
  project_id      = var.host_project_id
  billing_account = var.billing_account_id

  auto_create_network = false
}

resource "google_project" "service" {
  name            = var.project_service
  project_id      = var.service_project_id
  billing_account = vari.billing_account_id

  auto_create_network = false
}


resource "google_project_service" "host_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ])

  project = google_project.host.project_id
  service = each.value

  disable_on_destroy = false
}

resource "google_project_service" "service_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "bigquery.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
  ])

  project = google_project.service.project_id
  service = each.value

  disable_on_destroy = false
}


