data "google_project" "service" {
  project_id = var.service_project_id
}

resource "google_service_account" "gke_nodes" {
  project      = var.service_project_id
  account_id   = "${var.cluster_name}-nodes-sa"
  display_name = "GKE Node Service Account - ${var.cluster_name}"
  description  = "Least-privilege service account for GKE nodes in ${var.environment}"
}

resource "google_project_iam_member" "gke_node_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
  ])

  project = var.service_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "main" {
  provider = google-beta

  project  = var.service_project_id
  name     = var.cluster_name
  location = var.region

  network    = var.vpc_id
  subnetwork = var.subnet_id

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.masters_cidr
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  workload_identity_config {
    workload_pool = "${var.service_project_id}.svc.id.goog"
  }

  datapath_provider = "ADVANCED_DATAPATH"

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    dns_cache_config {
      enabled = true
    }
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
    ]

    managed_prometheus {
      enabled = true
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T02:00:00Z"
      end_time   = "2024-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  resource_labels = {
    environment = var.environment
    managed-by  = "terraform"
    cluster     = var.cluster_name
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
    ]
  }
}

resource "google_container_node_pool" "pools" {
  for_each = var.node_pools

  provider = google-beta

  project    = var.service_project_id
  name       = each.key
  cluster    = google_container_cluster.main.id
  location   = var.region

  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  initial_node_count = each.value.initial_count

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    strategy        = "SURGE"
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type
    preemptible  = each.value.preemptible

    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = merge(each.value.labels, {
      environment = var.environment
      managed-by  = "terraform"
    })

    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["gke-node", "gke-${var.cluster_name}"]
  }

  lifecycle {
    create_before_destroy = true
  }
}