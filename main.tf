module "network" {
  source   = "./modules/network"
  project  = var.project_id
  region   = var.region
  vpc_name = "${var.vpc_name}-${var.env}"
  subnets  = var.subnets
}

module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
  env        = var.env
}

module "gke" {
  source          = "./modules/gke"
  project_id      = var.project_id
  region          = var.region
  locations       = var.gke_locations
  cluster_name    = "${var.gke_name}-${var.env}"
  network_self    = module.network.network_self_link
  subnetwork_self = module.network.app_subnet_self_link
  min_nodes       = var.gke_min_nodes
  max_nodes       = var.gke_max_nodes
  machine_type    = var.gke_machine_type
  master_cidr     = "172.16.0.0/28"
  bastion_cidr    = module.network.bastion_cidr
}

module "ot_sim" {
  source            = "./modules/ot_sim_gce"
  project_id        = var.project_id
  region            = var.region
  network_self_link = module.network.network_self_link
  subnetwork_self   = module.network.ot_subnet_self_link
  instance_count    = var.ot_instance_count
  machine_type      = var.ot_machine_type
  startup_container = var.ot_startup_container
}

module "cicd" {
  source                 = "./modules/cicd"
  project_id             = var.project_id
  region                 = var.region
  artifact_repo_location = var.artifact_repo_location
  artifact_repo_id       = var.artifact_repo_id
  env                    = var.env
  gke_cluster_name       = module.gke.cluster_name
  gke_cluster_location   = module.gke.location
  github_owner           = var.github_owner
  github_repo            = var.github_repo
  github_branch          = var.github_branch
}

# Data to wire kubernetes provider after GKE exists
data "google_container_cluster" "this" {
  name     = module.gke.cluster_name
  location = module.gke.location
}
