data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "lab-k8s-bootstrap-tfstate"
    prefix = "bootstrap/state"
  }
}

locals {
  host_project_id    = data.terraform_remote_state.bootstrap.outputs.host_project_ids["develop"]
  service_project_id = data.terraform_remote_state.bootstrap.outputs.service_project_ids["develop"]
}

module "networking" {
  source = "../../modules/networking"

  host_project_id    = local.host_project_id
  service_project_id = local.service_project_id
  region             = var.region
  vpc_name           = var.vpc_name
  nodes_cidr         = var.nodes_cidr
  pods_cidr          = var.pods_cidr
  services_cidr      = var.services_cidr
  masters_cidr       = var.masters_cidr
  onprem_cidr        = var.onprem_cidr
  onprem_vpn_ip      = var.onprem_vpn_ip
  vpn_shared_secret  = var.vpn_shared_secret
  gcp_asn            = var.gcp_asn
}

module "gke" {
  source = "../../modules/gke"

  host_project_id    = local.host_project_id
  service_project_id = local.service_project_id
  region             = var.region
  environment        = "develop"

  cluster_name        = var.cluster_name
  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.subnet_id
  pods_range_name     = module.networking.pods_range_name
  services_range_name = module.networking.services_range_name
  masters_cidr        = var.masters_cidr

  authorized_networks = var.authorized_networks
  node_pools          = var.node_pools
  release_channel     = "REGULAR"
}


module "iam" {
  source = "../../modules/iam"

  host_project_id    = local.host_project_id
  service_project_id = local.service_project_id
  environment        = "develop"
  gke_node_sa_email  = module.gke.node_service_account_email
  app_sa_email       = module.gke.app_service_account_email
}

module "database" {
  source = "../../modules/database"

  service_project_id        = local.service_project_id
  region                    = var.region
  environment               = "develop"
  network_id                = module.networking.vpc_id
  private_service_access_id = module.networking.service_networking_connection
  db_tier                   = var.db_tier
  availability_type         = var.availability_type
}

module "observability" {
  source = "../../modules/observability"

  service_project_id = local.service_project_id
  region             = var.region
  environment        = "develop"
  cluster_name       = module.gke.cluster_name
  notification_email = var.notification_email
  api_uptime_url     = var.api_uptime_url
}