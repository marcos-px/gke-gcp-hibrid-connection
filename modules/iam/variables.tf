variable "host_project_id" {
  description = "Host project ID"
  type        = string
}

variable "service_project_id" {
  description = "Service project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "gke_node_sa_email" {
  description = "GKE node service account email"
  type        = string
}

variable "app_sa_email" {
  description = "Application service account email"
  type        = string
}

variable "github_actions_tf_sa_email" {
  description = "GitHub Actions Terraform service account email"
  type        = string
}