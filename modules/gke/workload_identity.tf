resource "google_service_account" "app" {
  project      = var.service_project_id
  account_id   = "${var.cluster_name}-app-sa"
  display_name = "Application Service Account - ${var.cluster_name}"
  description  = "GSA bound to KSA via Workload Identity for the application workload"
}

resource "google_project_iam_member" "app_sa_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
  ])

  project = var.service_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${var.service_project_id}.svc.id.goog[app/app-ksa]"
}