terraform {
    backend "gcs" {
        bucket = "phj-devsecops-bucket"
        prefix  = "cicd/devsecops/terraform/state"
    }
}