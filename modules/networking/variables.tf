variable "host_project_id" {
  type        = string
  description = "HOST PROJECT ID"
}

variable "vpc_name" {
  type        = string
  description = "VPC NAME"
}

variable "region" {
  type        = string
  description = "REGION for VPC"
}

variable "nodes_cidr" {
  type        = string
  description = "Nodes IPs"
}

variable "pods_cidr" {
  type        = string
  description = "Secondary ips"
}

variable "services_cidr" {
  type = string

  description = "Services cidr"
}

variable "service_project_id" {
  type        = string
  description = "Service Project ID"
}

variable "gcp_asn" {
  type        = string
  description = "GCP Asn number"
}

variable "masters_cidr" {
  type        = string
  description = "Masters Cidrs range"
}

variable "onprem_cidr" {
  type        = string
  description = "On premises cidrs ips"
}

variable "onprem_vpn_ip" {
  type        = string
  description = "On premises vpn ip"
}

variable "vpn_shared_secret" {
  type        = string
  description = "Shaed Secrets VPN"
}