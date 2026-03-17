variable "region" {
  type        = string
  description = "Project region"
}

variable "vpc_name" {
  type        = string
  description = "VPC base name used as prefix"
}

variable "nodes_cidr" {
  type        = string
  description = "Primary CIDR for GKE nodes subnet"
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  type        = string
  description = "Secondary range for GKE pods"
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  type        = string
  description = "Secondary range for GKE services"
  default     = "10.2.0.0/20"
}

variable "masters_cidr" {
  type        = string
  description = "CIDR reserved for GKE control plane"
  default     = "10.3.0.0/28"
}

variable "onprem_cidr" {
  type        = string
  description = "On-premise network CIDR"
}

variable "onprem_vpn_ip" {
  description = "On Prem VPN IP"
  type        = string
}

variable "vpn_shared_secret" {
  description = "PSK for Tunnel HA VPN"
  type        = string
  sensitive   = true
}

variable "gcp_asn" {
  description = "GCP ASN"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "lab-k8s-cluster-dev"
}

variable "authorized_networks" {
  description = "CIDRs authorized to access the GKE control plane"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
}

variable "node_pools" {
  description = "Node pool configurations"
  type = map(object({
    machine_type   = string
    disk_size_gb   = number
    disk_type      = string
    min_node_count = number
    max_node_count = number
    initial_count  = number
    preemptible    = bool
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
}

variable "notification_email" {
  description = "Email for alert notifications"
  type        = string
}

variable "api_uptime_url" {
  description = "API hostname for uptime check (leave empty to skip)"
  type        = string
  default     = ""
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "Cloud SQL availability: ZONAL or REGIONAL"
  type        = string
  default     = "ZONAL"
}