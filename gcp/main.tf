# Firewall rule for GCP instances
resource "google_compute_firewall" "default" {
  name    = "devops-firewall"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "9090", "50000"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["devops-vm"]
}

# Prometheus Server (GCP VM 1)
resource "google_compute_instance" "prometheus" {
  name         = "prometheus-server"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
    }
  }

  network_interface {
    network = var.network_name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y prometheus
    sudo systemctl enable prometheus
    sudo systemctl start prometheus
  EOF

  tags = ["devops-vm"]

  labels = {
    environment = "production"
    role        = "monitoring"
  }
}

# Grafana Server (GCP VM 2)
resource "google_compute_instance" "grafana" {
  name         = "grafana-server"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
    }
  }

  network_interface {
    network = var.network_name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apt-transport-https software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install -y grafana
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server
  EOF

  tags = ["devops-vm"]

  labels = {
    environment = "production"
    role        = "visualization"
  }
}

# Output for instance IPs
output "prometheus_external_ip" {
  value       = google_compute_instance.prometheus.network_interface[0].access_config[0].nat_ip
  description = "Prometheus server external IP"
}

output "grafana_external_ip" {
  value       = google_compute_instance.grafana.network_interface[0].access_config[0].nat_ip
  description = "Grafana server external IP"
}
