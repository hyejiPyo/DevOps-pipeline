data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}


# GCP 기존 VPC 참조
data "google_compute_network" "default" {
    name    = "default"
    project = var.gcp_project
}



data "google_compute_network" "custom" {
    count = var.use_existing_gcp_network ? 1 : 0
    name = "custom-network"
    project = var.gcp_project
}

locals {
    network_id = var.use_existing_gcp_network ? data.google_compute_network.custom[0].id : google_compute_network.custom[0].id
}

data "google_compute_subnetwork" "custom" {
    count = var.use_existing_subnet ? 1 : 0
    name = "custom-subnet"
    region = var.gcp_region
    project = var.gcp_project
}

locals {
    subnet_self_link = var.use_existing_subnet ? data.google_compute_subnetwork.custom[0].self_link : google_compute_subnetwork.custom[0].self_link
}