resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.service_project_id
  secret_id = "db-password-${var.environment}"

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

resource "google_secret_manager_secret" "db_connection_string" {
  project   = var.service_project_id
  secret_id = "db-connection-string-${var.environment}"

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "google_secret_manager_secret_version" "db_connection_string" {
  secret = google_secret_manager_secret.db_connection_string.id
  secret_data = "postgresql://${var.db_user}:${random_password.db.result}@${google_sql_database_instance.main.private_ip_address}:5432/${var.db_name}"
}

resource "google_sql_database_instance" "main" {
  project             = var.service_project_id
  name                = "lab-k8s-pg-${var.environment}"
  region              = var.region
  database_version    = var.db_version
  deletion_protection = true

  settings {
    tier              = var.db_tier
    availability_type = var.availability_type
    disk_size         = var.disk_size_gb
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    user_labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  depends_on = [var.private_service_access_id]
}

resource "google_sql_database" "main" {
  project  = var.service_project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_name
}

resource "google_sql_user" "app" {
  project  = var.service_project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_user
  password = random_password.db.result
}