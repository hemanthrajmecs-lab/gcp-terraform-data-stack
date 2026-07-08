# Root module. Wires the four building blocks together.
# Each module can also be used on its own if you only need part of the stack.

module "bigquery" {
  source = "./modules/bigquery"

  project_id = var.project_id
  env        = var.env
  location   = var.location
}

module "gcs" {
  source = "./modules/gcs"

  project_id = var.project_id
  env        = var.env
  location   = var.location
}

module "iam" {
  source = "./modules/iam"

  project_id = var.project_id
  env        = var.env
}

module "composer" {
  source = "./modules/composer"

  project_id          = var.project_id
  env                 = var.env
  region              = var.region
  deploy              = var.deploy_composer
  node_count          = var.composer_node_count
  worker_service_acct = module.iam.pipeline_sa_email
}
