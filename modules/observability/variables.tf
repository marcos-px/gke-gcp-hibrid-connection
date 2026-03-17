variable "service_project_id" {
  description = "Service project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name for dashboard and alert filters"
  type        = string
}

variable "notification_email" {
  description = "Email for alerting notifications"
  type        = string
}

variable "api_uptime_url" {
  description = "Public URL of the API for uptime check"
  type        = string
  default     = ""
}