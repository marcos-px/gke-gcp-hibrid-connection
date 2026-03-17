resource "google_artifact_registry_repository" "app" {
  for_each = toset(var.environments)

  project       = google_project.service[each.value].project_id
  location      = var.region
  repository_id = "app-images-${local.env_suffix[each.value]}"
  format        = "DOCKER"
  description   = "Docker images for the hybrid app in ${each.value} environment"

  depends_on = [google_project_service.service_apis]
}