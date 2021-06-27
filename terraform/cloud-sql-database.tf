resource "google_sql_database" "database" {
  name     = "books"
  instance = google_sql_database_instance.postgres.name
}