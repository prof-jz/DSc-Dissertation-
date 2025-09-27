# GCP Digital Twin CI/CD (Terraform)

This scaffold spins up **networking**, a **private GKE cluster**, **OT simulator VMs** (e.g., OpenPLC/Modbus), and **CI/CD** (Artifact Registry, Cloud Build trigger, Cloud Deploy). Apply twice with `env=dev` and `env=test` to create two distinct environments in the same project, or in separate projects by switching `project_id`.

## Prereqs
- Terraform >= 1.5
- gcloud auth login; gcloud auth application-default login
- Enable APIs:
  ```bash
  gcloud services enable compute.googleapis.com container.googleapis.com \
    containeranalysis.googleapis.com cloudbuild.googleapis.com \
    artifactregistry.googleapis.com clouddeploy.googleapis.com iam.googleapis.com
  ```
- Optional: Set up **GitHub App** connection in Cloud Build UI (once per project).

## Configure
Copy `env.auto.tfvars.example` to `env.auto.tfvars` and set values:
```hcl
project_id = "YOUR_PROJECT"
region     = "us-central1"
env        = "dev" # then run again with "test"
github_owner  = "YOUR_GH_ORG"
github_repo   = "YOUR_REPO"
github_branch = "main"
```

## Deploy
```bash
terraform init
terraform apply -auto-approve
```
Repeat with `env = "test"` (and optionally a different `project_id`).

## Build & Deploy app
Add a `cloudbuild.yaml` to your repo, e.g.:
```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build','-t','${_IMAGE}','.']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push','${_IMAGE}']
- name: 'gcr.io/cloud-builders/kubectl'
  args:
    - "apply"
    - "-f"
    - "k8s/twin-namespace.yaml"
    - "-f"
    - "k8s/twin-app-deployment.yaml"
    - "-f"
    - "k8s/twin-app-service.yaml"
  env:
    - "CLOUDSDK_COMPUTE_REGION=${_REGION}"
    - "CLOUDSDK_CONTAINER_CLUSTER=${_CLUSTER}"
substitutions:
  _REGION: "us-central1"
  _CLUSTER: "dtwin-gke-dev"
  _IMAGE: "us-docker.pkg.dev/$PROJECT_ID/dtwin-repo/twin-app:$SHORT_SHA"
images:
- "us-docker.pkg.dev/$PROJECT_ID/dtwin-repo/twin-app:$SHORT_SHA"
```

Use Cloud Deploy if you want automated promotion from **dev** to **test** (configure release manifests with two targets `gke-dev` and `gke-test`).

## Security Notes
- GKE is **private**; access via bastion or Cloud Shell + `master_authorized_networks`.
- No public IPs on OT VMs; egress via **Cloud NAT**.
- Firewall allows only Modbus (TCP 502) from app subnet to OT.
- Use **Workload Identity** for K8s → GCP access.
- Tighten IAM before production (least privilege).

## Extending for Compliance/Threat Scans
- Add a `security` namespace and deploy scanners (e.g., Falco/eBPF, Trivy, Anchore) via Helm.
- Integrate **InSpec/OpenSCAP** into Cloud Build steps for compliance-as-code.
- Mirror real PLC/RTU protocols (DNP3, IEC 60870-5-104) by adjusting firewall + simulator containers.

## Destruction
```bash
terraform destroy
