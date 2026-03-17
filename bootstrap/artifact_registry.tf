resource "google_artifact_registry_repository" "app" {
    project = google_project.service.project_id
    location = var.region
    repository_id = "app-images"
    format = "DOCKER"
    description = "Images Docker for Hibrid App"

    depends_on = [google_project_service.service_apis]
}

