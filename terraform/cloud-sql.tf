resource "google_sql_database_instance" "postgres" {
  project = var.project_id
  name             = "${var.project_id}-postgres-instance"
  database_version = "POSTGRES_13"
  region           = var.region

  settings {
    # Second-generation instance tiers are based on the machine type.
    tier = "db-f1-micro"

    # Since autoresize is enables, we are not specifying disk size.
    disk_autoresize = true
    disk_type = "PD_SSD"

    # The availability type of the Cloud SQL instance, 
    # high availability (REGIONAL) or single zone (ZONAL).
    availability_type = "ZONAL"
    location_preference {
        # The preferred compute engine zone
        zone = var.zone
    }

    ip_configuration {
        # Whether this Cloud SQL instance should be assigned a public IPV4 address.
        ipv4_enabled = true
    }

    backup_configuration {
      enabled = true
      start_time = "04:30"
    }

    # Maintenance window can be set as per reqiurement.
    # maintenance_window {
    #   day  = "1"
    #   hour = "4"
    # }
    
  }
  # (Default: true ) Whether or not to allow Terraform to destroy the instance. 
  # Unless this field is set to false in Terraform state, a terraform destroy or terraform 
  # apply command that deletes the instance will fail.
  deletion_protection = false
}

// Provision a super user
resource "google_sql_user" "super-user" {
  project = var.project_id
  name     = "postgres"

  #  The name of the Cloud SQL instance.
  instance = google_sql_database_instance.postgres.name

  # The user type. It determines the method to authenticate the user during login. 
  # The default is the database's built-in user type.
  # Flags include "BUILT_IN", "CLOUD_IAM_USER", or "CLOUD_IAM_SERVICE_ACCOUNT".
  type     = "BUILT_IN"

  # The password for the user. Can be updated. 
  # For Postgres instances this is a Required field.
  password = var.postgres_user_password
}

// Provision the database
resource "google_sql_database" "database" {
  project = var.project_id
  name     = "books"
  instance = google_sql_database_instance.postgres.name
}

