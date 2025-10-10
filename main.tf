provider "google" {
    project = "DevOps"
    region = var.gcp_region
}

provider "aws" {
    region = var.aws_region
}

resource "google_compute_instance" "jenkins_ci" {
  name         = "jenkins-ci"
  machine_type = "e2-medium"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  metadata = {
    ssh-keys = var.gcp_metadata_ssh_keys
  }

  network_interface {
    network = "data.google_compute_network.default.self_link"
    access_config {}
  }
}

# 네트워크 생성 - GCP
resource "google_comopute_network" "custom" {
    count = var.use_existing_gcp_network ? 0 : 1
    name = "custom-network"
    auto_create_subnetworks = false
}

# 서브넷 생성 - GCP
resource "google_compute_subnetwork" "custom" {
    count = var.use_existing_subnet ? 0 : 1
    name = "custom-subnet"
    ip_cidr_range = "10.0.0.0/24"
    region = var.gcp_region
    network = local.network_id
}

resource "google_compute_instance" "jenkins_agent" {
  name         = "jenkins-agent"
  machine_type = "e2-medium"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  metadata = {
    ssh-keys = var.gcp_metadata_ssh_keys
  }

  network_interface {
    network = "data.google_compute_network.default.self_link"
    access_config {}
  }
}

resource "aws_ecr_repository" "jenkins_image" {
  name = "jenkins-docker-image"
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3.medium"
  key_name      = var.aws_key_name

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_eip" "jenkins_server_eip" {
    instance = aws_instance.jenkins_server.id
    vpc = true
}

resource "aws_instance" "prometheus" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3.medium"
  key_name      = var.aws_key_name

  tags = {
    Name = "prometheus"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y prometheus
    # 추가 설정
  EOF
}

# Jenkins Agent Server(EC2) - Docker 설치 및 ECR에서 이미지 pull 후 컨테이너 실행
resource "aws_instance" "app_server" {
  ami           = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3.medium"
  key_name      = var.aws_key_name

  tags = {
    Name = "app-server"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io
    aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <your_aws_account_id>.dkr.ecr.ap-northeast-2.amazonaws.com
    docker pull <your_aws_account_id>.dkr.ecr.ap-northeast-2.amazonaws.com/jenkins-docker-image:latest
    docker run -d --name app <your_aws_account_id>.dkr.ecr.ap-northeast-2.amazonaws.com/jenkins-docker-image:latest
  EOF
}