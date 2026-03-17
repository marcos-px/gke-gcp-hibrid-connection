resource "google_bigquery_dataset" "logs" {
  project                    = var.service_project_id
  dataset_id                 = "app_logs_${var.environment}"
  location                   = var.region
  description                = "Application logs sink for ${var.environment}"
  delete_contents_on_destroy = false

  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

resource "google_logging_project_sink" "app_logs" {
  project     = var.service_project_id
  name        = "app-logs-to-bq-${var.environment}"
  description = "Sink filtered application logs to BigQuery"

  destination = "bigquery.googleapis.com/projects/${var.service_project_id}/datasets/${google_bigquery_dataset.logs.dataset_id}"

  filter = <<-EOT
    resource.type="k8s_container"
    resource.labels.cluster_name="${var.cluster_name}"
    severity>=WARNING
  EOT

  bigquery_options {
    use_partitioned_tables = true
  }

  unique_writer_identity = true
}

resource "google_bigquery_dataset_iam_member" "log_sink_writer" {
  project    = var.service_project_id
  dataset_id = google_bigquery_dataset.logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.app_logs.writer_identity
}

resource "google_monitoring_notification_channel" "email" {
  project      = var.service_project_id
  display_name = "Email - ${var.environment}"
  type         = "email"

  labels = {
    email_address = var.notification_email
  }
}

resource "google_monitoring_alert_policy" "pod_restarts" {
  project      = var.service_project_id
  display_name = "Pod Restart Count High - ${var.environment}"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Pod restarts > 3 in 5 minutes"

    condition_threshold {
      filter = <<-EOT
        resource.type = "k8s_container"
        AND resource.labels.cluster_name = "${var.cluster_name}"
        AND metric.type = "kubernetes.io/container/restart_count"
      EOT

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.labels.pod_name"]
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 3
      duration        = "0s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = "Pod ${var.cluster_name} is restarting frequently. Check logs: `kubectl logs <pod> -n app --previous`"
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_alert_policy" "node_cpu" {
  project      = var.service_project_id
  display_name = "Node CPU High - ${var.environment}"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Node CPU utilization > 80%"

    condition_threshold {
      filter = <<-EOT
        resource.type = "k8s_node"
        AND resource.labels.cluster_name = "${var.cluster_name}"
        AND metric.type = "kubernetes.io/node/cpu/allocatable_utilization"
      EOT

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }
}

resource "google_monitoring_alert_policy" "node_memory" {
  project      = var.service_project_id
  display_name = "Node Memory High - ${var.environment}"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Node memory utilization > 85%"

    condition_threshold {
      filter = <<-EOT
        resource.type = "k8s_node"
        AND resource.labels.cluster_name = "${var.cluster_name}"
        AND metric.type = "kubernetes.io/node/memory/allocatable_utilization"
      EOT

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison      = "COMPARISON_GT"
      threshold_value = 0.85
      duration        = "300s"
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  alert_strategy {
    auto_close = "1800s"
  }
}

resource "google_monitoring_uptime_check_config" "api" {
  count = var.api_uptime_url != "" ? 1 : 0

  project      = var.service_project_id
  display_name = "API Uptime - ${var.environment}"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path           = "/health"
    port           = "443"
    use_ssl        = true
    validate_ssl   = true
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.service_project_id
      host       = var.api_uptime_url
    }
  }
}

resource "google_monitoring_dashboard" "gke" {
  project        = var.service_project_id
  dashboard_json = jsonencode({
    displayName = "GKE Overview - ${var.environment}"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Pod Restart Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_container\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/container/restart_count\""
                    aggregation = {
                      alignmentPeriod    = "300s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.labels.pod_name"]
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        },
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "Node CPU Utilization"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_node\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\""
                    aggregation = {
                      alignmentPeriod  = "300s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        },
        {
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Node Memory Utilization"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_node\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/node/memory/allocatable_utilization\""
                    aggregation = {
                      alignmentPeriod  = "300s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        },
        {
          xPos   = 6
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Running Pods per Namespace"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_pod\" AND resource.labels.cluster_name=\"${var.cluster_name}\" AND metric.type=\"kubernetes.io/pod/volume/total_bytes\""
                    aggregation = {
                      alignmentPeriod    = "300s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_COUNT"
                      groupByFields      = ["resource.labels.namespace_name"]
                    }
                  }
                }
                plotType = "STACKED_BAR"
              }]
            }
          }
        }
      ]
    }
  })
}