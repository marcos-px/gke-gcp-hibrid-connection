output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "cluster_id" {
  description = "GKE cluster full resource ID"
  value       = google_container_cluster.main.id
}

output "cluster_endpoint" {
  description = "GKE control plane endpoint (private IP)"
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = google_container_cluster.main.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "node_service_account_email" {
  description = "Service account email used by GKE nodes"
  value       = google_service_account.gke_nodes.email
}

output "app_service_account_email" {
  description = "GSA email bound to the application KSA via Workload Identity"
  value       = google_service_account.app.email
}

output "workload_pool" {
  description = "Workload Identity pool for the cluster"
  value       = "${var.service_project_id}.svc.id.goog"
}

output "kubeconfig_command" {
  description = "Command to update local kubeconfig for this cluster"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.service_project_id}"
}