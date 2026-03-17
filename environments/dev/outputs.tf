resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../ansible/inventory/inventory.yml"

  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    region                     = var.region
    host_project_id            = local.host_project_id
    service_project_id         = local.service_project_id
    artifact_registry_url      = data.terraform_remote_state.bootstrap.outputs.artifact_registry_urls["develop"]
    workload_identity_provider = data.terraform_remote_state.bootstrap.outputs.workload_identity_providers["develop"]
    github_actions_tf_sa       = data.terraform_remote_state.bootstrap.outputs.github_actions_tf_sas["develop"]
    github_actions_app_sa      = data.terraform_remote_state.bootstrap.outputs.github_actions_app_sas["develop"]

    vpc_name                = module.networking.vpc_name
    cluster_name            = module.gke.cluster_name
    cluster_endpoint        = module.gke.cluster_endpoint
    db_instance_name        = module.database.instance_name
    db_private_ip           = module.database.private_ip_address
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
    GCP_HOST_PROJECT=${local.host_project_id}
    GCP_SERVICE_PROJECT=${local.service_project_id}
    GCP_REGION=${var.region}
    GKE_CLUSTER=${module.gke.cluster_name}
    ARTIFACT_REGISTRY=${data.terraform_remote_state.bootstrap.outputs.artifact_registry_urls["develop"]}
    DB_INSTANCE=${module.database.instance_name}
    WIF_PROVIDER=${data.terraform_remote_state.bootstrap.outputs.workload_identity_providers["develop"]}
    TF_SA=${data.terraform_remote_state.bootstrap.outputs.github_actions_tf_sas["develop"]}
    APP_SA=${data.terraform_remote_state.bootstrap.outputs.github_actions_app_sas["develop"]}
  EOT

  file_permission = "0600"
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE control plane private endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "db_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.database.instance_name
}

output "db_private_ip" {
  description = "Cloud SQL private IP"
  value       = module.database.private_ip_address
  sensitive   = true
}

output "vpc_name" {
  description = "Shared VPC name"
  value       = module.networking.vpc_name
}

output "vpn_gateway_ips" {
  description = "HA VPN public IPs"
  value = {
    interface_0 = module.networking.vpn_gateway_ip_0
    interface_1 = module.networking.vpn_gateway_ip_1
  }
}

output "artifact_registry_url" {
  description = "Artifact Registry URL for this environment"
  value       = data.terraform_remote_state.bootstrap.outputs.artifact_registry_urls["develop"]
}

output "monitoring_dashboard_id" {
  description = "Cloud Monitoring dashboard ID"
  value       = module.observability.dashboard_id
}
