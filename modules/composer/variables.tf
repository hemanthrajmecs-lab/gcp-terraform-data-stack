variable "project_id" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "deploy" {
  description = "Set to true to actually create the environment"
  type        = bool
  default     = false
}

variable "node_count" {
  type    = number
  default = 3
}

variable "worker_service_acct" {
  description = "Service account the Airflow workers run as"
  type        = string
}
