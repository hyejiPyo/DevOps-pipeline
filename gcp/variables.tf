variable "gcp_project" {
  description = "DevOps"
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

variable "gcp_ssh_user" {
  description = "GCP 인스턴스 SSH 사용자명"
  type        = string
  default     = "hyeji"
}

variable "gcp_metadata_ssh_keys" {
  description = "GCP 인스턴스 metadatda의 SSH-KEYS 값"
  type        = string
  default = "hyeji:ssh-rsa /Z+Ba1gMO4dLm/I6vbOBf+YiJ3DtS+8lPE3sK/NmTFTeDlSYYuRHp7vqhDnHwF/4B+V6TmUPdbnfRS7/UP3usg7zD5m5XM4dzTomI6MPf1mapEq6ArqeSBPRLHqn31icjME/oUB4GxNbH20uTpibgkhfvAU= hyeji"
}

# gcp 네트워크 생성 (생성 후 default 값 true로 변경 필요)
variable "use_existing_gcp_network" {
  description = "기존 GCP 네트워크 사용 여부 (true면 data, false면 resource)"
  type = bool
  default = false
}

variable "use_existing_subnet" {
  description = "기존 서브넷 사용 여부 (true면 data, false면 resource)"
  type = bool
  default = false
}