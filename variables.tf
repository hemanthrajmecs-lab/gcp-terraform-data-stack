variable "project_id" {
  description = "GCP project to deploy into"
  type        = string
}

variable "region" {
  description = "Default region for regional resources"
  type        = string
  default     = "us-central1"
}

variable "env" {
  description = "Environment name (dev, prod). Used as a suffix on most resource names."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "env must be dev or prod."
  }
}

variable "location" {
  description = "Location for BigQuery datasets and GCS buckets (US or a specific region)"
  type        = string
  default     = "US"
}

variable "deploy_composer" {
  description = "Whether to create the Cloud Composer environment. Off by default because Composer is the slowest and most expensive piece."
  type        = bool
  default     = false
}

variable "composer_node_count" {
  description = "Node count for the Composer environment"
  type        = number
  default     = 3
}
