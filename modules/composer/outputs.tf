output "environment_name" {
  value = var.deploy ? google_composer_environment.this[0].name : null
}
