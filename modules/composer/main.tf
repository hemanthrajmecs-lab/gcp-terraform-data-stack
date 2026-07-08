# Cloud Composer 2 environment. Gated behind var.deploy because spinning
# one up takes ~25 minutes and costs real money even when idle.

resource "google_composer_environment" "this" {
  count = var.deploy ? 1 : 0

  name    = "data-orchestration-${var.env}"
  project = var.project_id
  region  = var.region

  config {
    software_config {
      image_version = "composer-2-airflow-2"

      env_variables = {
        DATA_ENV = var.env
      }
    }

    node_config {
      service_account = var.worker_service_acct
    }

    workloads_config {
      scheduler {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
        count      = 1
      }
      worker {
        cpu        = 1
        memory_gb  = 4
        storage_gb = 5
        min_count  = 1
        max_count  = var.node_count
      }
    }
  }

  labels = {
    env     = var.env
    managed = "terraform"
  }
}
