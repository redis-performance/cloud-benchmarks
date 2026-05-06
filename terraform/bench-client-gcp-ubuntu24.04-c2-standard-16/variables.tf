################################################################################
# Variables used for deployment tag
################################################################################

variable "setup_name" {
  description = "setup name"
  default     = "bench-client-gcp-ubuntu24-c2-standard-16"
}

variable "github_actor" {
  description = "The name of the person or app that initiated the deployment."
  default     = "N/A"
}

variable "github_repo" {
  description = "The owner and repository name. For example, testing-infrastructure."
  default     = "N/A"
}

variable "triggering_env" {
  description = "The triggering environment. For example circleci."
  default     = "N/A"
}

variable "environment" {
  description = "The cost tag."
  default     = "BENCH-CLIENT"
}

variable "github_org" {
  description = "The owner name. For example, RedisModules."
  default     = "N/A"
}

variable "github_sha" {
  description = "The commit SHA that triggered the deployment."
  default     = "N/A"
}

variable "timeout_secs" {
  description = "The maximum time to wait prior destroying the VM via the watchdog."
  default     = "3600"
}

################################################################################
# GCP Configuration
################################################################################

variable "project_id" {
  description = "GCP project ID"
  default     = "your-gcp-project"
}

variable "region" {
  description = "GCP region"
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone"
  default     = "us-east1-b"
}

variable "network" {
  description = "GCP network name"
  default     = "default"
}

variable "subnet" {
  description = "GCP subnet name"
  default     = "default"
}

################################################################################
# Instance Configuration
################################################################################

variable "machine_type" {
  description = "GCP machine type (equivalent to AWS c7i.4xlarge)"
  default     = "c2-standard-16"  # 16 vCPUs, 64 GB RAM
}

variable "instance_count" {
  description = "Number of GCP instances"
  default     = 1
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  default     = 256
}

variable "boot_disk_type" {
  description = "Boot disk type"
  default     = "pd-ssd"
}

variable "image_family" {
  description = "OS image family"
  default     = "ubuntu-2404-lts-amd64"
}

variable "image_project" {
  description = "OS image project"
  default     = "ubuntu-os-cloud"
}

variable "ssh_user" {
  description = "SSH user"
  default     = "ubuntu"
}

variable "private_key_path" {
  description = "Path to private key file"
  default     = "/tmp/benchmarks.redislabs.pem"
}

variable "public_key_path" {
  description = "Path to public key file"
  default     = "/tmp/benchmarks.redislabs.pem.pub"
}
