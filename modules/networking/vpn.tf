resource "google_compute_ha_vpn_gateway" "gcp_side" {
  project = var.host_project_id
  name    = "${var.vpc_name}-ha-vpn-gw"
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_external_vpn_gateway" "onprem" {
  project     = var.host_project_id
  name        = "onprem-real-vpn-gw"
  description = "Gateway VPN on-premise"

  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"

  interface {
    id         = 0
    ip_address = var.onprem_vpn_ip
  }
}

resource "google_compute_vpn_tunnel" "gcp_to_onprem_0" {
  project = var.host_project_id
  name    = "${var.vpc_name}-tunnel-0"
  region  = var.region

  vpn_gateway           = google_compute_ha_vpn_gateway.gcp_side.id
  vpn_gateway_interface = 0

  peer_external_gateway           = google_compute_external_vpn_gateway.onprem.id
  peer_external_gateway_interface = 0

  ike_version   = 2
  shared_secret = var.vpn_shared_secret
  router        = google_compute_router.main.id
}

resource "google_compute_vpn_tunnel" "gcp_to_onprem_1" {
  project                         = var.host_project_id
  name                            = "${var.vpc_name}-tunnel-1"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.gcp_side.id
  vpn_gateway_interface           = 1
  peer_external_gateway           = google_compute_external_vpn_gateway.onprem.id
  peer_external_gateway_interface = 0
  ike_version                     = 2
  shared_secret                   = var.vpn_shared_secret
  router                          = google_compute_router.main.id
}