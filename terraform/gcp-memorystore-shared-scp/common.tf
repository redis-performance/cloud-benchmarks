terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.20"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.20"
    }
  }
  required_version = ">= 1.3"
}

provider "google" {
  project = "your-gcp-project"
  region  = "us-east1"
  zone    = "us-east1-b"
}
