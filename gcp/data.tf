data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}


data "google_compute_network" "custom" {
  name    = "default"
  project = var.gcp_project
}

data "google_compute_subnetwork" "custom" {
  name    = "default"
  region  = var.gcp_region
  project = var.gcp_project
}

locals {
  network_id        = data.google_compute_network.custom.id
  network_self_link = data.google_compute_network.custom.self_link
  subnet_self_link  = data.google_compute_subnetwork.custom.self_link
}