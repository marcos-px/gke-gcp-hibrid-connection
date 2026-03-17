variable "host_project_id" {
  description = "Host project ID that owns the Shared VPC"
  type        = string
}

variable "service_project_id" {
  description = "Service project ID where GKE cluster will run"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "lab-k8s-cluster"
}

variable "vpc_id" {
  description = "VPC network ID from networking module"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for GKE nodes from networking module"
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods"
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services"
  type        = string
}

variable "masters_cidr" {
  description = "CIDR block for GKE control plane (/28 required)"
  type        = string
}

variable "authorized_networks" {
  description = "List of CIDRs authorized to access the GKE control plane endpoint"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "node_pools" {
  description = "Map of node pool configurations"
  type = map(object({
    machine_type    = string
    disk_size_gb    = number
    disk_type       = string
    min_node_count  = number
    max_node_count  = number
    initial_count   = number
    preemptible     = bool
    labels          = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    general = {
      machine_type   = "e2-standard-2"
      disk_size_gb   = 50
      disk_type      = "pd-standard"
      min_node_count = 1
      max_node_count = 3
      initial_count  = 1
      preemptible    = true
      labels = {
        role = "general"
      }
      taints = []
    }
  }
}

variable "environment" {
  description = "Environment name (develop | staging | production)"
  type        = string
  default     = "develop"
}

variable "release_channel" {
  description = "GKE release channel (RAPID | REGULAR | STABLE)"
  type        = string
  default     = "REGULAR"
}