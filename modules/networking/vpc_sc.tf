resource "google_access_context_manager_access_policy" "main" {
  parent = "organizations/${var.org_id}"
  title  = "lab-k8s-policy"
}

resource "google_access_context_manager_service_perimeter" "main" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.main.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.main.name}/servicePerimeters/lab_k8s_perimeter"
  title  = "lab-k8s-perimeter"

  status {
    resources = [
      "projects/${data.google_project.service.number}",
    ]

    restricted_services = [
      "bigquery.googleapis.com",
      "storage.googleapis.com",
      "sqladmin.googleapis.com",
      "secretmanager.googleapis.com",
      "container.googleapis.com",
    ]

    vpc_accessible_services {
      enable_restriction = true
      allowed_services = [
        "bigquery.googleapis.com",
        "storage.googleapis.com",
        "sqladmin.googleapis.com",
        "secretmanager.googleapis.com",
        "container.googleapis.com",
        "logging.googleapis.com",
        "monitoring.googleapis.com",
      ]
    }
  }
}