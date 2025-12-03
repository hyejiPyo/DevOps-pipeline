variable "gcp_project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP 리전"
  type        = string
  default     = "asia-northeast3"
}

variable "gcp_zone" {
  description = "GCP 존"
  type        = string
  default     = "asia-northeast3-a"
}

variable "machine_type" {
  description = "GCP VM 인스턴스 타입"
  type        = string
  default     = "e2-medium"
}

variable "network_name" {
  description = "GCP VPC 네트워크 이름"
  type        = string
  default     = "default"
}
