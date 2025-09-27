resource "google_service_account" "gke_nodes" {
  account_id   = replace("${var.cluster_name}-nodes", "_", "-")
  display_name = "GKE Node SA for ${var.cluster_name}"
}

resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region

  network    = var.network_self
  subnetwork = var.subnetwork_self

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel { channel = "REGULAR" }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr
  }

  ip_allocation_policy {}

  master_authorized_networks_config {
    cidr_blocks = [
      { cidr_block = var.bastion_cidr, display_name = "bastion" }
    ]
  }

  workload_identity_config { workload_pool = "${var.project_id}.svc.id.goog" }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}

resource "google_container_node_pool" "np" {
  name       = "default-pool"
  location   = var.region
  cluster    = google_container_cluster.cluster.name
  node_count = var.min_nodes

  autoscaling { min_node_count = var.min_nodes max_node_count = var.max_nodes }

  node_config {
    machine_type = var.machine_type
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    metadata = { disable-legacy-endpoints = "true" }
    tags     = ["gke-node"]
  }
}
