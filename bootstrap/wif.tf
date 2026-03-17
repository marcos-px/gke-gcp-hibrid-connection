resource "google_iam_workload_identity_pool" "github" {
  for_each = toset(var.environments)

  project                   = google_project.service[each.value].project_id
  workload_identity_pool_id = "github-pool-${local.env_suffix[each.value]}"
  display_name              = "GitHub Actions Pool - ${each.value}"
  description               = "OIDC identity pool for GitHub Actions in ${each.value} environment"

  depends_on = [google_project_service.service_apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  for_each = toset(var.environments)

  project                            = google_project.service[each.value].project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github[each.value].workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider-${local.env_suffix[each.value]}"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "attribute.repository == \"${var.github_org}/${var.terraform_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "github_actions_tf" {
  for_each = toset(var.environments)

  project      = google_project.service[each.value].project_id
  account_id   = "github-actions-tf-${local.env_suffix[each.value]}"
  display_name = "GitHub Actions Terraform - ${each.value}"
  description  = "Impersonated by WIF to run terraform plan/apply in ${each.value}"
}

resource "google_service_account_iam_binding" "github_wif_tf" {
  for_each = toset(var.environments)

  service_account_id = google_service_account.github_actions_tf[each.value].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[each.value].name}/attribute.repository/${var.github_org}/${var.terraform_repo}"
  ]
}

resource "google_service_account" "github_actions_app" {
  for_each = toset(var.environments)

  project      = google_project.service[each.value].project_id
  account_id   = "github-actions-app-${local.env_suffix[each.value]}"
  display_name = "GitHub Actions App Build - ${each.value}"
  description  = "Impersonated by WIF to push images to Artifact Registry in ${each.value}"
}

resource "google_service_account_iam_binding" "github_wif_app" {
  for_each = toset(var.environments)

  service_account_id = google_service_account.github_actions_app[each.value].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github[each.value].name}/attribute.repository/${var.github_org}/${var.app_repo}"
  ]
}

resource "google_project_iam_member" "app_sa_registry" {
  for_each = toset(var.environments)

  project = google_project.service[each.value].project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_app[each.value].email}"
}