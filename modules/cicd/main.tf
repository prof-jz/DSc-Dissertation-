resource "google_artifact_registry_repository" "repo" {
  location      = var.artifact_repo_location
  repository_id = var.artifact_repo_id
  description   = "Digital twin container repo"
  format        = "DOCKER"
}

# Cloud Build trigger (GitHub). You must connect GitHub in Cloud Build UI once per project.
resource "google_cloudbuild_trigger" "github_docker_build" {
  name        = "dtwin-build-${var.env}"
  description = "Build & push Docker image to Artifact Registry"

  github {
    owner = var.github_owner
    name  = var.github_repo
    push { branch = var.github_branch }
  }

  filename = "cloudbuild.yaml"
}

# Cloud Deploy: pipeline and targets (dev/test handled by applying with different env)
resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  location     = var.region
  name         = "dtwin-pipeline"
  description  = "Kubernetes CD for digital twin"
}

resource "google_clouddeploy_target" "gke_target" {
  location    = var.region
  name        = "gke-${var.env}"
  description = "Target ${var.env}"
  gke {
    cluster = "projects/${var.project_id}/locations/${var.gke_cluster_location}/clusters/${var.gke_cluster_name}"
  }
  depends_on = [google_clouddeploy_delivery_pipeline.pipeline]
}
