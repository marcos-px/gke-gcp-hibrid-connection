output "dashboard_id" {
  description = "Monitoring dashboard ID"
  value       = google_monitoring_dashboard.gke.id
}

output "log_sink_name" {
  description = "Logging sink name"
  value       = google_logging_project_sink.app_logs.name
}

output "bigquery_dataset" {
  description = "BigQuery dataset ID for logs"
  value       = google_bigquery_dataset.logs.dataset_id
}

output "notification_channel_id" {
  description = "Email notification channel ID"
  value       = google_monitoring_notification_channel.email.name
}

output "pod_restart_alert_id" {
  description = "Alert policy ID for pod restarts"
  value       = google_monitoring_alert_policy.pod_restarts.name
}