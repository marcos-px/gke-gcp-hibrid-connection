output "dev_engineer_role_id" {
  description = "Custom role ID for dev engineers"
  value       = google_project_iam_custom_role.dev_engineer.id
}

output "ops_engineer_role_id" {
  description = "Custom role ID for ops engineers"
  value       = google_project_iam_custom_role.ops_engineer.id
}