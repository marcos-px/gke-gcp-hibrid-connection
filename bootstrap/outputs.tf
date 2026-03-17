output "host_project_id" {
  value       = google_project.host.project_id
  description = "Host project ID - Networking module required"
}

output "service_project_id" {
  value       = google_project.service.project_id
  description = "Service Project ID - GKE and app required"
}

output "workload_identity_provider" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Resource name WIF Provider"
}

output "github_actions_tf_sa" {
  value       = google_service_account.github_actions_tf.email
  description = "SA Email with Terraform"
}

output "github_actions_app_sa" {
  value       = google_service_account.github_actions_app.email
  description = "SA Email with App"
}

output "artifact_registry_url" {
  value       = "${var.region}-docker.pkg.dev/${google_project.service.project_id}/app-images"
  description = "URL base Artifact Registry"

}
