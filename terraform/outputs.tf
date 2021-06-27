output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "cloud_sql_instance_connection_name" {
    value = google_sql_database_instance.postgres.connection_name
    description = "Cloud SQL Instance Connection Name"
}

output "cloud_sql_instance_service_account" {
    value = google_sql_database_instance.postgres.service_account_email_address
    description = "Cloud SQL Instance Service Account"
}