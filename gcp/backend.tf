terraform {
  backend "gcs" {
    bucket = "phj-devsecops-bucket"
    prefix = "gcp/devsecops/terraform/state"
  }
}