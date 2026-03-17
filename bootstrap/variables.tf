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

variable "github_org" {
  type        = string
  description = "User or org with Github"
}

variable "terraform_repo" {
  type        = string
  description = "Name of terraform repo"
}

variable "app_repo" {
  type        = string
  description = "Name of app repo"
}

variable "org_id" {
  type        = string
  description = "GCP Organization numeric ID."

}

variable "environments" {
  type        = list(string)
  default     = ["develop", "staging", "production"]
  description = "List of environment names to create as GCP folders"

}

variable "active_environment" {
  type        = string
  description = "Active environment for this Terraform workspace (develop | staging | production)"

}