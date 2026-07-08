# Prod environment. Same shape as dev, different state prefix and sizing.

terraform {
  required_version = ">= 1.5"

  backend "gcs" {
    bucket = "tf-state-gcp-data-stack"
    prefix = "env/prod"
  }
}

module "stack" {
  source = "../.."

  project_id          = var.project_id
  region              = var.region
  env                 = "prod"
  deploy_composer     = var.deploy_composer
  composer_node_count = 5
}

variable "project_id" { type = string }
variable "region" {
  type    = string
  default = "us-central1"
}
variable "deploy_composer" {
  type    = bool
  default = true
}

output "stack" {
  value = {
    datasets = module.stack.bigquery_datasets
    buckets  = module.stack.gcs_buckets
    sas      = module.stack.service_accounts
  }
}
