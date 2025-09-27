provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Will be configured after cluster creation via data sources
provider "kubernetes" {
  host                   = try(data.google_container_cluster.this.endpoint, null) == null ? null : "https://${data.google_container_cluster.this.endpoint}"
  cluster_ca_certificate = try(base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate), null)
  token                  = try(data.google_client_config.default.access_token, null)
}

data "google_client_config" "default" {}
