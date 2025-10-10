data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# AWS 기존 VPC 참조
data "aws_vpc" "default" {
    default = true
    id = "vpc-08289defd1ea10e6f"
}

# GCP 기존 VPC 참조
data "google_compute_network" "default" {
    name    = "default"
    project = var.gcp_project
}

# AWS 기존 Subnet 참조
data "aws_subnet" "default" {
    filter{
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
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
    count = var.use_exsting_subnet ? 1 : 0
    name = "custome-subnet"
    region = var.gcp_region
    project = var.gcp_project
}

locals {
    subnet_self_link = var.use_existing_subnet ? data.google_compute_subnetwork.custom[0].self_link : google_compute_subnetwork.custom[0].self_link
}