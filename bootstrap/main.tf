provider "google" {
  region = var.region
}

provider "google-beta" {
  region = var.region
}

resource "google_folder" "environments" {
  for_each = toset(var.environments)

  display_name = each.value

  parent = "organizations/${var.org_id}"

  lifecycle {
    prevent_destroy = false
  }
}

locals {
  env_suffix = {
    develop    = "dev"
    staging    = "stg"
    production = "prd"
  }
}
resource "google_project" "host" {
  for_each        = toset(var.environments)
  name            = "lab-k8s-host-${local.env_suffix[each.value]}"
  project_id      = "lab-k8s-host-${local.env_suffix[each.value]}"
  billing_account = var.billing_account_id

  folder_id = google_folder.environments[each.value].name


  auto_create_network = false
  deletion_policy = "PREVENT"

  lifecycle {
    prevent_destroy = false
    ignore_changes = [ 
        billing_account,
        org_id,
     ]
  }
}

resource "google_project" "service" {
  for_each = toset(var.environments)

  name            = "lab-k8s-svc-${local.env_suffix[each.value]}"
  project_id      = "lab-k8s-svc-${local.env_suffix[each.value]}"
  billing_account = var.billing_account_id

  folder_id = google_folder.environments[each.value].name

  auto_create_network = false
  deletion_policy = "PREVENT"

lifecycle {
    prevent_destroy = false
    ignore_changes = [ 
        billing_account,
        org_id,
     ]
  }
}

locals {
  host_api_combinations = {
    for combo in setproduct(var.environments, [
      "compute.googleapis.com",
      "servicenetworking.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "accesscontextmanager.googleapis.com",
      "logging.googleapis.com",
      "monitoring.googleapis.com",
      ]) : "${combo[0]}-${combo[1]}" => {
      env = combo[0]
      api = combo[1]
    }
  }

  service_api_combinations = {
    for combo in setproduct(var.environments, [
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
      ]) : "${combo[0]}-${combo[1]}" => {
      env = combo[0]
      api = combo[1]
    }
  }
}

resource "google_project_service" "host_apis" {
  for_each = local.host_api_combinations

  project            = google_project.host[each.value.env].project_id
  service            = each.value.api
  disable_on_destroy = false
}

resource "google_project_service" "service_apis" {
  for_each = local.service_api_combinations

  project            = google_project.service[each.value.env].project_id
  service            = each.value.api
  disable_on_destroy = false
}

