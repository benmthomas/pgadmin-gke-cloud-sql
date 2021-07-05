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
  description = "The zone to host the cluster in"
  default = "us-central1-b"
}

variable "gke_num_nodes" {
  description = "number of gke nodes"
  default     = 1
}