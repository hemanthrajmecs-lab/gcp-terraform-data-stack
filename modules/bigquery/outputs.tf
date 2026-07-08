output "dataset_ids" {
  value = { for k, ds in google_bigquery_dataset.layer : k => ds.dataset_id }
}
