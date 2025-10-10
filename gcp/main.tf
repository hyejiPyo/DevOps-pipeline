provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

resource "google_compute_instance" "jenkins_ci" {
  name         = "jenkins-ci"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.gcp_image
    }
  }

  metadata = {
    ssh-keys = "${var.gcp_ssh_user}:${var.gcp_ssh_pubkey} ${var.gcp_ssh_user}"
  }

  network_interface {
    network    = var.gcp_network_self_link
    subnetwork = var.gcp_subnet_self_link
    access_config {}
  }
}

resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network = var.gcp_network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
