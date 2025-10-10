provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# 사용자 계정 생성 및 권한 추가
resource "google_service_account" "terraform" {
  account_id   = "terraform-sa"
  display_name = "Terraform Service Account"
}

resource "google_project_iam_member" "compute_admin" {
  project = var.gcp_project
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.gcp_project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "sa_user" {
  project = var.gcp_project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# Jenkins Agent Server(Junit 테스트 필요)
resource "google_compute_instance" "jenkins_agent" {
  name         = "jenkins-agent"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.gcp_image
    }
  }

  metadata = {
    ssh-keys = var.gcp_metadata_ssh_keys
    user-data = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y docker.io
      sudo systemctl enable docker
      sudo systemctl start docker
      curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
    EOF
  }

  network_interface {
    network    = var.gcp_network_self_link
    subnetwork = var.gcp_subnet_self_link
    access_config {}
  }

  tags = ["jenkins-agent"]
}

# Jenkins Server(CI)
resource "google_compute_instance" "jenkins_server" {
  name         = "jenkins-server"
  machine_type = var.gcp_machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.gcp_image
    }
  }

  metadata = {
    ssh-keys = var.gcp_metadata_ssh_keys
    user-data = <<-EOF
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y openjdk-11-jdk
      wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
      sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
      sudo apt-get update
      sudo apt-get install -y jenkins
      sudo systemctl enable jenkins
      sudo systemctl start jenkins
    EOF
  }

  network_interface {
    network    = var.gcp_network_self_link
    subnetwork = var.gcp_subnet_self_link
    access_config {}
  }

  tags = ["jenkins-server"]
}

  network_interface {
    network    = var.gcp_network_self_link
    subnetwork = var.gcp_subnet_self_link
    access_config {}
  }

resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network = var.gcp_network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "50000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

