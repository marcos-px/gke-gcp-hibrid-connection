variable "region" {
  type        = string
  default     = "southamerica-east1"
  description = "Region of GCP"
}

variable "project_host" {
  type        = string
  default     = "lab-k8s-host"
  description = "Name of project host"
}

variable "host_project_id" {
  type        = string
  default     = "lab-k8s-host"
  description = "ID of project host"
}

variable "billing_account_id" {
  type        = string
  description = "Billing account ID"
}

variable "project_service" {
  type        = string
  default     = "lab-k8s-service"
  description = "Name of project service"
}

variable "service_project_id" {
  type        = string
  default     = "lab-k8s-service"
  description = "Project service id"
}
