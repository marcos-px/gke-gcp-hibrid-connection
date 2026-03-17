resource "google_iam_workload_identity_pool" "github" {
  project                   = google_project.service.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "Github Actions Pool"
  description               = "OIDC Identity with Github Actionss"

  depends_on = [google_project_service.service_apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = google_project.service.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"

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
    project = google_project.service.project_id
    account_id = "github-actions-tf"
    display_name = "Github Actions - Terraform"
    description = "Impersonate with WIF terraform"      
}

resource "google_service_account_iam_binding" "github_wif_tf" {
    service_account_id = google_service_account.github_actions_tf.name
    role = "roles/iam.workloadIdentityUser"

    members = [     "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.terraform_repo}"
 ]
}

resource "google_service_account" "github_actions_app" {
    project = google_project.service.project_id
    account_id = "github-actions-app"
    display_name = "Github Actions - App"
    description = "Impersonate with WIF for push in Artifact Registry"

}

resource "google_service_account_iam_binding" "github_wif_app" {
  service_account_id = google_service_account.github_actions_app.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.app_repo}"
  ]
}

resource "google_project_iam_member" "app_sa_registry" {
  project = google_project.service.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions_app.email}"
}