resource "google_project_iam_custom_role" "dev_engineer" {
  project     = var.service_project_id
  role_id     = "devEngineer${title(var.environment)}"
  title       = "Dev Engineer - ${var.environment}"
  description = "Read-only access to workloads and logs for dev engineers"

  permissions = [
    "container.clusters.get",
    "container.clusters.list",
    "container.pods.get",
    "container.pods.list",
    "container.pods.getLogs",
    "container.deployments.get",
    "container.deployments.list",
    "container.services.get",
    "container.services.list",
    "logging.logEntries.list",
    "monitoring.timeSeries.list",
    "monitoring.dashboards.get",
    "secretmanager.versions.list",
    "secretmanager.secrets.list",
    "cloudsql.instances.get",
    "cloudsql.instances.list",
    "artifactregistry.repositories.get",
    "artifactregistry.tags.list",
  ]
}

resource "google_project_iam_custom_role" "ops_engineer" {
  project     = var.service_project_id
  role_id     = "opsEngineer${title(var.environment)}"
  title       = "Ops Engineer - ${var.environment}"
  description = "Operational access for infra management, no IAM changes"

  permissions = [
    "container.clusters.get",
    "container.clusters.list",
    "container.clusters.update",
    "container.nodePools.get",
    "container.nodePools.list",
    "container.nodePools.update",
    "container.pods.get",
    "container.pods.list",
    "container.pods.getLogs",
    "container.pods.exec",
    "container.deployments.get",
    "container.deployments.list",
    "container.deployments.update",
    "container.services.get",
    "container.services.list",
    "logging.logEntries.list",
    "logging.sinks.get",
    "logging.sinks.list",
    "monitoring.timeSeries.list",
    "monitoring.dashboards.get",
    "monitoring.dashboards.list",
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list",
    "secretmanager.secrets.get",
    "secretmanager.secrets.list",
    "secretmanager.versions.get",
    "secretmanager.versions.list",
    "secretmanager.versions.access",
    "cloudsql.instances.get",
    "cloudsql.instances.list",
    "cloudsql.instances.restart",
    "compute.networks.get",
    "compute.subnetworks.get",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "artifactregistry.repositories.get",
    "artifactregistry.tags.list",
    "artifactregistry.tags.get",
  ]
}

resource "google_project_iam_member" "github_actions_tf_roles" {
  for_each = toset([
    "roles/container.admin",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/secretmanager.admin",
    "roles/cloudsql.admin",
    "roles/bigquery.admin",
    "roles/monitoring.admin",
    "roles/logging.admin",
    "roles/artifactregistry.admin",
    "roles/resourcemanager.projectIamAdmin",
  ])

  project = var.service_project_id
  role    = each.value
  member  = "serviceAccount:${var.github_actions_tf_sa_email}"
}

resource "google_project_iam_member" "github_actions_tf_host_roles" {
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
  ])

  project = var.host_project_id
  role    = each.value
  member  = "serviceAccount:${var.github_actions_tf_sa_email}"
}