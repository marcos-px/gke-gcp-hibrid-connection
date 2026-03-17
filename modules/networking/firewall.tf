resource "google_compute_firewall" "deny_all_ingress_log" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-deny-all-ingress"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 65534
  description = "deny all ingress"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_health-checks" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-allow-health-checks"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1000
  description = "allow health-checks"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  target_tags = ["gke-node"]
}

resource "google_compute_firewall" "allow_internal_gke" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-allow-gke-internal"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1000
  description = "allow-gke-itnernal for nodes, pods and services"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.nodes_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]

  target_tags = ["gke-node"]
}

resource "google_compute_firewall" "allow_master_to_nodes" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-allow-master-to-nodes"
  network     = google_compute_network.main.id
  direction   = "INGRESS"
  priority    = 1000
  description = "allow communication for control plane GKE for nodes"

  allow {
    protocol = "tcp"

    ports = [
      "443",
      "8443",
      "10250",
      "10255",
    ]
  }

  source_ranges = [var.masters_cidr]

  target_tags = ["gke-node"]

}

resource "google_compute_firewall" "deny_all_egress" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-deny-all-egress"
  network     = google_compute_network.main.id
  direction   = "EGRESS"
  priority    = 65534
  description = "deny all egress"

  deny {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_egress_google_apis" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-allow-egress-google-apis"
  network     = google_compute_network.main.id
  direction   = "EGRESS"
  priority    = 1000
  description = "allor egress google apis"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["199.36.153.8/30", "199.36.153.4/30"]
  target_tags        = ["gke-node"]
}

resource "google_compute_firewall" "allow_egress_to_onprem" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-allow-egress-onprem"
  network     = google_compute_network.main.id
  direction   = "EGRESS"
  priority    = 1000
  description = "allow egress to onprem"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  allow {
    protocol = "icmp"
  }

  destination_ranges = [var.onprem_cidr]
  target_tags        = ["gke-node"]
}

resource "google_compute_firewall" "allow_egress_internet_nat" {
  project     = var.host_project_id
  name        = "${var.vpc_name}-allow-egress-internet"
  network     = google_compute_network.main.id
  direction   = "EGRESS"
  priority    = 1100
  description = "Allow egress for internet via NAT Gateway"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["gke-node"]
}