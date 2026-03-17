output "folder_ids" {
  description = "GCP folder by environment name"
  value = {
    for env in var.environments :
    env => google_folder.environments[env].folder_id
  }
}

output "host_project_ids" {
  description = "Host project IDs indexed by environment name"
  value = {
    for env in var.environments :
    env => google_project.host[env].project_id
  }
}

output "service_project_ids" {
  description = "Service project IDs indexed by environment name"
  value = {
    for env in var.environments :
    env => google_project.service[env].project_id
  }
}

output "workload_identity_providers" {
  description = "WIF provider resource names indexed by environment — add to GitHub Secrets"
  value = {
    for env in var.environments :
    env => google_iam_workload_identity_pool_provider.github[env].name
  }
}

output "github_actions_tf_sas" {
  description = "Terraform service account emails indexed by environment"
  value = {
    for env in var.environments :
    env => google_service_account.github_actions_tf[env].email
  }
}

output "github_actions_app_sas" {
  description = "App build service account emails indexed by environment"
  value = {
    for env in var.environments :
    env => google_service_account.github_actions_app[env].email
  }
}

output "artifact_registry_urls" {
  description = "Artifact Registry base URLs indexed by environment"
  value = {
    for env in var.environments :
    env => "${var.region}-docker.pkg.dev/${google_project.service[env].project_id}/app-images-${local.env_suffix[env]}"
  }
}
