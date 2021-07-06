# vars.tf
# Defines project-specific variables that can be injected into other
# HCL files using "${var.var_name}" syntax.

# ==[ Project variables ]================================================

variable "project_id" {
  type = string
  description = "Google Cloud project ID (not name)"
  default = "stately-minutia-318001"
}

variable "region" {
  description = "The region to host the cluster in"
  default = "us-central1"
}

variable "zone" {
  description = "The zone to host the cloud sql database"
  default = "us-central1-b"
}

variable "gke_num_nodes" {
  description = "number of gke nodes"
  default     = 1
}

# ==[ Credentials ]======================================================

variable "postgres_user_password" {
  type = string
  description = "The password of postgres database user"
  sensitive = true
}