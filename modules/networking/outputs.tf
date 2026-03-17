output "vpc_id" {
  description = "VPC Id from self link"
  value       = google_compute_network.main.id
}

output "vpc_name" {
  description = "VPC name for GKE Cluster rules"
  value       = google_compute_network.main.name
}

output "subnet_id" {
  description = "Subnet id for nodes"
  value       = google_compute_subnetwork.gke_nodes.id
}

output "subnet_name" {
  description = "Nodes subnets names"
  value       = google_compute_subnetwork.gke_nodes.name
}

output "pods_range_name" {
  description = "secondary range pods"
  value       = "pods"
}

output "services_range_name" {
  description = "secondary name for services"
  value       = "services"
}

output "vpn_gateway_ip_0" {
  description = "Public IP from VPN — interface 0"
  value       = google_compute_ha_vpn_gateway.gcp_side.vpn_interfaces[0].ip_address
}

output "vpn_gateway_ip_1" {
  description = "Public IP from VPN — interface 1"
  value       = google_compute_ha_vpn_gateway.gcp_side.vpn_interfaces[1].ip_address
}

output "private_service_access_range" {
  description = "IP Range from PSA"
  value       = google_compute_global_address.private_service_access.address
}

output "service_networking_connection" {
  description = "PSA Connection"
  value       = google_service_networking_connection.private_service_access.id
}

output "masters_cidr" {
  description = "Master -- nodes Cidrs"
  value       = var.masters_cidr
}

output "gcp_vpn_ip_tunnel_0" {
  description = "Public IP from GCP HA VN - eth0"
  value       = google_compute_ha_vpn_gateway.gcp_side.vpn_interfaces[0].ip_address
}

output "gcp_vpn_ip_tunnel_1" {
  description = "Public IP from GCP HA VN - eth1"
  value       = google_compute_ha_vpn_gateway.gcp_side.vpn_interfaces[1].ip_address
}