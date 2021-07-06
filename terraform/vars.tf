# vars.tf
# Defines project-specific variables that can be injected into other
# HCL files using "${var.var_name}" syntax.

# Project variables

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


# Optional values that can be overridden or appended to if desired.

variable "gke_num_nodes" {
  description = "number of gke nodes"
  default     = 1
}

variable "k8s_namespace" {
  type        = string
  description = "The namespace to use for the deployment and workload identity binding"
  default     = "default"
}


variable "db_username" {
  type        = string
  description = "The name for the DB connection"
  default     = "postgres"
}

variable "db_password" {
  type = string
  description = "The password of postgres database user"
  sensitive = true
}

variable "project_services" {
  type = list
  description = "The GCP APIs that should be enabled in this project."
  default = [
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "securetoken.googleapis.com",
  ]
}