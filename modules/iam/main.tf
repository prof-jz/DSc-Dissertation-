# Minimal roles; tighten per least-privilege for prod
resource "google_service_account" "cicd" {
  account_id   = "dtwin-cicd-${var.env}"
  display_name = "CI/CD SA ${var.env}"
}

resource "google_project_iam_member" "cicd_roles" {
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/cloudbuild.builds.editor",
    "roles/container.admin",
    "roles/iam.serviceAccountUser",
    "roles/logging.admin",
    "roles/monitoring.admin",
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

output "cicd_sa_email" { value = google_service_account.cicd.email }