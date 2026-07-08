output "bigquery_datasets" {
  description = "Dataset IDs for the three medallion layers"
  value       = module.bigquery.dataset_ids
}

output "gcs_buckets" {
  description = "Names of the landing, archive and temp buckets"
  value       = module.gcs.bucket_names
}

output "service_accounts" {
  description = "Emails of the three service accounts"
  value       = module.iam.service_account_emails
}

output "composer_environment" {
  description = "Composer environment name (null if deploy_composer = false)"
  value       = module.composer.environment_name
}
