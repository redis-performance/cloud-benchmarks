
terraform {
  required_providers {
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      # The RCP control plane rejected our applies as
      # "INCOMPATIBLE_TF_PROVIDER" with 2.1.5 — bumping to the latest stable
      # 2.x line. (AWS cells in this repo run on 2.10.2 today; the GCP path
      # appears to need newer.)
      version = "~> 2.15"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
  }
  required_version = ">= 1.3"

  # Local backend to mirror the rest of the gcp-redis-cloud-* cells.
  # backend "gcs" {
  #   bucket = "your-gcp-project-terraform-state"
  #   prefix = "benchmarks/infrastructure"
  # }
}

provider "google" {
  project = "your-gcp-project"
  region  = "us-east1"
  zone    = "us-east1-b"
}

data "external" "env" {
  program = ["${path.module}/env.sh"]
}
