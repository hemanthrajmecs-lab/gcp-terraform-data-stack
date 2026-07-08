# Three datasets, one per medallion layer.
# raw      = data exactly as it landed, never edited by hand
# staging  = cleaned and conformed, still row-level
# analytics = aggregated, business-facing tables

locals {
  datasets = {
    raw = {
      friendly_name = "Raw (bronze)"
      description   = "Source data as ingested. Append only, no manual edits."
      # Raw data gets stale fast, expire partitions after 90 days
      default_partition_expiration_ms = 90 * 24 * 60 * 60 * 1000
    }
    staging = {
      friendly_name                   = "Staging (silver)"
      description                     = "Cleaned, deduplicated, typed. Input for analytics models."
      default_partition_expiration_ms = null
    }
    analytics = {
      friendly_name                   = "Analytics (gold)"
      description                     = "Business-facing marts. What dashboards and analysts query."
      default_partition_expiration_ms = null
    }
  }
}

resource "google_bigquery_dataset" "layer" {
  for_each = local.datasets

  dataset_id    = "${each.key}_${var.env}"
  project       = var.project_id
  location      = var.location
  friendly_name = each.value.friendly_name
  description   = each.value.description

  default_partition_expiration_ms = each.value.default_partition_expiration_ms

  labels = {
    env     = var.env
    layer   = each.key
    managed = "terraform"
  }
}

# One example table so the raw layer is not empty on day one.
# Real ingestion jobs create their own tables.
resource "google_bigquery_table" "ingestion_log" {
  dataset_id          = google_bigquery_dataset.layer["raw"].dataset_id
  project             = var.project_id
  table_id            = "ingestion_log"
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "loaded_at"
  }

  schema = jsonencode([
    { name = "source", type = "STRING", mode = "REQUIRED", description = "Where the batch came from" },
    { name = "row_count", type = "INT64", mode = "NULLABLE" },
    { name = "loaded_at", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "status", type = "STRING", mode = "NULLABLE" }
  ])
}
