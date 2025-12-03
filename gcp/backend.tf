terraform {
  backend "gcs" {
    bucket = "phj-devsecops-gcp-bucket"
    prefix = "gcp/devsecops/terraform.tfstate"
  }
}
