terraform {
  backend "s3" {
    bucket = "phj-devsecops-bucket"
    key    = "aws/devsecops/terraform.tfstate"
    region = "ap-northeast-2"
  }
}