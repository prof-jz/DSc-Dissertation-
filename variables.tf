variable "project_id" { type = string }
variable "region"     { type = string  default = "us-central1" }
variable "gke_locations" { type = list(string) default = ["us-central1"] }

# Distinct environment labels (dev/test) using same project or separate projects if you run twice
variable "env" { type = string description = "Environment label: dev or test" }

# Networking
variable "vpc_name" { type = string default = "dtwin-vpc" }
variable "subnets" {
  description = "Map of subnet definitions: name => { cidr, purpose }"
  type = map(object({
    cidr    = string
    purpose = string # mgmt | app | ot
  }))
  default = {
    mgmt = { cidr = "10.10.0.0/24", purpose = "mgmt" }
    app  = { cidr = "10.20.0.0/24", purpose = "app" }
    ot   = { cidr = "10.30.0.0/24", purpose = "ot" }
  }
}

# GKE
variable "gke_name"        { type = string default = "dtwin-gke" }
variable "gke_min_nodes"   { type = number default = 1 }
variable "gke_max_nodes"   { type = number default = 3 }
variable "gke_machine_type"{ type = string default = "e2-standard-4" }

# OT simulators
variable "ot_instance_count" { type = number default = 2 }
variable "ot_machine_type"   { type = string default = "e2-standard-2" }
variable "ot_startup_container" {
  type        = string
  description = "Container image to run on OT simulator (e.g., OpenPLC, ModbusTCP sim)"
  default     = "docker.io/thiagoralves/openplc:latest"
}

# Artifact Registry + CI/CD
variable "artifact_repo_location" { type = string default = "us" }
variable "artifact_repo_id"       { type = string default = "dtwin-repo" }
variable "github_owner"           { type = string default = null }
variable "github_repo"            { type = string default = null }
variable "github_branch"          { type = string default = "main" }

