terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.30"
    }
  }

  # Remote state lives in GCS. Create this bucket once by hand
  # (or with a bootstrap script), then run terraform init.
  backend "gcs" {
    bucket = "tf-state-gcp-data-stack"
    prefix = "state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
