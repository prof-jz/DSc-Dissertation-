variable "project_id"             { type = string }
variable "region"                 { type = string }
variable "artifact_repo_location" { type = string }
variable "artifact_repo_id"       { type = string }
variable "env"                    { type = string }
variable "gke_cluster_name"       { type = string }
variable "gke_cluster_location"   { type = string }
variable "github_owner"           { type = string, default = null }
variable "github_repo"            { type = string, default = null }
variable "github_branch"          { type = string, default = "main" }