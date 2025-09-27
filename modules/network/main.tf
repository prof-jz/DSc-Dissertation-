resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# Create subnets for mgmt, app, ot
resource "google_compute_subnetwork" "subnets" {
  for_each               = var.subnets
  name                   = "${var.vpc_name}-${each.key}"
  ip_cidr_range          = each.value.cidr
  region                 = var.region
  network                = google_compute_network.vpc.id
  private_ip_google_access = true
}

# Cloud Router + NAT for egress without public IPs
resource "google_compute_router" "nat_router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Bastion host in mgmt subnet
resource "google_compute_instance" "bastion" {
  name         = "${var.vpc_name}-bastion"
  machine_type = "e2-standard-2"
  zone         = "${var.region}-a"

  boot_disk { initialize_params { image = "projects/debian-cloud/global/images/family/debian-12" } }

  network_interface {
    subnetwork = google_compute_subnetwork.subnets["mgmt"].self_link
    # No external IP — access via IAP or VPN; uncomment to allow ephemeral external IP for initial setup
    # access_config {}
  }

  tags = ["bastion"]
  metadata = {
    enable-oslogin = "TRUE"
  }
}

# Strict firewall: allow IAP SSH to bastion, allow GKE <-> OT on Modbus (502) + ICMP for testing
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.vpc_name}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  allow { protocol = "tcp" ports = ["22"] }
  source_ranges = ["35.235.240.0/20"] # IAP TCP range
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "gke_to_ot_modbus" {
  name    = "${var.vpc_name}-gke-to-ot-modbus"
  network = google_compute_network.vpc.name

  allow { protocol = "tcp" ports = ["502"] }
  allow { protocol = "icmp" }

  source_ranges = [google_compute_subnetwork.subnets["app"].ip_cidr_range]
  target_tags   = ["ot-sim"]
}

