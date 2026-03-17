data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "lab-k8s-bootstrap-tfstate"
    prefix = "bootstrap/state"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../ansible/inventory/inventory.yml"

  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    region                     = var.region
    host_project_id            = data.terraform_remote_state.bootstrap.outputs.host_project_id
    service_project_id         = data.terraform_remote_state.bootstrap.outputs.service_project_id
    artifact_registry_url      = data.terraform_remote_state.bootstrap.outputs.artifact_registry_url
    workload_identity_provider = data.terraform_remote_state.bootstrap.outputs.workload_identity_provider
    github_actions_tf_sa       = data.terraform_remote_state.bootstrap.outputs.github_actions_tf_sa
    github_actions_app_sa      = data.terraform_remote_state.bootstrap.outputs.github_actions_app_sa

    vpc_name                = module.networking.vpc_name
    cluster_name            = module.gke.cluster_name
    cluster_endpoint        = module.gke.cluster_endpoint
    db_instance_name        = module.database.instance_name
    db_private_ip           = module.database.private_ip
    db_name                 = module.database.database_name
    monitoring_dashboard_id = module.observability.dashboard_id
    log_sink_name           = module.observability.log_sink_name
    bigquery_dataset        = module.observability.bigquery_dataset
  })

  file_permission = "0600"
}

resource "local_file" "env_file" {
  filename = "${path.module}/../../.env.generated"

  content = <<-EOT
    # Gerado automaticamente pelo Terraform — não editar manualmente
    # Fonte da verdade: terraform state

    GCP_HOST_PROJECT=${data.terraform_remote_state.bootstrap.outputs.host_project_id}
    GCP_SERVICE_PROJECT=${data.terraform_remote_state.bootstrap.outputs.service_project_id}
    GCP_REGION=${var.region}
    GKE_CLUSTER=${module.gke.cluster_name}
    ARTIFACT_REGISTRY=${data.terraform_remote_state.bootstrap.outputs.artifact_registry_url}
    DB_INSTANCE=${module.database.instance_name}
    WIF_PROVIDER=${data.terraform_remote_state.bootstrap.outputs.workload_identity_provider}
    TF_SA=${data.terraform_remote_state.bootstrap.outputs.github_actions_tf_sa}
    APP_SA=${data.terraform_remote_state.bootstrap.outputs.github_actions_app_sa}
  EOT

  file_permission = "0600"
}