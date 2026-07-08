# Dev environment. Run terraform commands from this directory:
#   cd environments/dev
#   terraform init && terraform plan

terraform {
  required_version = ">= 1.5"

  backend "gcs" {
    bucket = "tf-state-gcp-data-stack"
    prefix = "env/dev"
  }
}

module "stack" {
  source = "../.."

  project_id      = var.project_id
  region          = var.region
  env             = "dev"
  deploy_composer = var.deploy_composer
}

variable "project_id" { type = string }
variable "region" {
  type    = string
  default = "us-central1"
}
variable "deploy_composer" {
  type    = bool
  default = false
}

output "stack" {
  value = {
    datasets = module.stack.bigquery_datasets
    buckets  = module.stack.gcs_buckets
    sas      = module.stack.service_accounts
  }
}
