variable "scp_name" {
  description = "ServiceConnectionPolicy name. Shared across all Memorystore Valkey deploys on this (network, gcp-memorystore) pair."
  default     = "valkey-cluster-scp"
}

variable "location" {
  description = "GCP region for the SCP."
  default     = "us-east1"
}

variable "network_name" {
  description = "VPC network the SCP applies to."
  default     = "default"
}

variable "subnet_name" {
  description = "Subnet that PSC consumer addresses are allocated from."
  default     = "default"
}

# Tagging-metadata variables passed by the deploy workflows. Ignored locally
# but declared so terraform plan -var=... doesn't error.
variable "github_actor" {
  default = ""
}
variable "github_repo" {
  default = ""
}
variable "github_org" {
  default = ""
}
variable "github_sha" {
  default = ""
}
variable "triggering_env" {
  default = ""
}
