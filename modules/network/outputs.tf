output "network_self_link" { value = google_compute_network.vpc.self_link }
output "app_subnet_self_link" { value = google_compute_subnetwork.subnets["app"].self_link }
output "ot_subnet_self_link"  { value = google_compute_subnetwork.subnets["ot"].self_link }
output "bastion_cidr"         { value = google_compute_subnetwork.subnets["mgmt"].ip_cidr_range }