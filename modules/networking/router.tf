resource "google_compute_router" "main" {
  project = var.host_project_id
  name    = "${var.vpc_name}-router"
  network = google_compute_network.main.id

  region = var.region

  bgp {
    asn = var.gcp_asn
  }

}

resource "google_compute_route" "onprem_primary" {
  project     = var.host_project_id
  name        = "route-to-onprem-primary"
  network     = google_compute_network.main.id
  description = "Primary route for on-premises"

  dest_range = var.onprem_cidr

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.gcp_to_onprem_0.id

  priority = 100
}

resource "google_compute_route" "onprem_failover" {
  project             = var.host_project_id
  name                = "route-to-onprem-failover"
  network             = google_compute_network.main.id
  description         = "Rota de failover para a rede on-premise via túnel 1"
  dest_range          = var.onprem_cidr
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.gcp_to_onprem_1.id
  priority            = 200
}