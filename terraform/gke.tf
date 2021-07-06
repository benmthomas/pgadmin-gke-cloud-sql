resource "google_service_account" "default" {
  provider = google

  account_id   = "gke-cluster-minimal-sa"
  display_name = "Minimal service account for GKE cluster"
  project      = var.project_id
}

# GKE cluster
# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "primary" {
  project = var.project_id
  name     = "${var.project_id}-gke"
  
  # Creating a zonal cluster since this is only an example and for quick provisioning
  location = var.zone

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # The selected k8s release channel. 
  # STABLE: Every few months upgrade cadence; Production users who need stability above all else
  release_channel {
    channel = "STABLE"
  }
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Enable Shielded Nodes features on all nodes in this cluster. Defaults to false
  enable_shielded_nodes = true

  # Enable workload identity for Cloud SQL authentication.
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  # Disable basic authentication and cert-based authentication.
  # Empty fields for username and password are how to "disable" the
  # credentials from being generated.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = "false"
    }
  }
  
  # Allow time for each operation to finish.
  timeouts {
    create = "40m" # Default is 40 minutes.
    read   = "40m" # Default is 40 minutes.
    update = "60m" # Default is 60 minutes.
    delete = "40m" # Default is 40 minutes.
  }
}

# Separately Managed Node Pool
# https://www.terraform.io/docs/providers/google/r/container_node_pool.html
resource "google_container_node_pool" "primary_nodes" {
  project = var.project_id
  name       = "${google_container_cluster.primary.name}-node-pool"
  # Creating a zonal node pool since this is only an example and for a quick provisioning
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  # Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.
  autoscaling {
      min_node_count = 1
      max_node_count = 3
  }
  
  # Auto repair any issues.
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  # Parameters used in creating the cluster's nodes.
  node_config {
    machine_type = "n1-standard-1"
    disk_type    = "pd-standard"
    image_type   = "COS"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      # "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      env     = var.project_id
      cluster = "${var.project_id}-gke"
    }

    # Enable workload identity on this node pool
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    # preemptible  = true

    tags         = ["gke-node", "${var.project_id}-gke"]

    metadata = {
      # https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
      disable-legacy-endpoints = "true"
    }
  }
  
  # Allow time for each operation to finish.
  timeouts {
    create = "30m" # Default is 30 minutes.
    update = "30m" # Default is 30 minutes.
    delete = "30m" # Default is 30 minutes.
  }
}


# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terrafoecho 'yamldecode(file("my-manifest-file.yaml"))' | terraform consolerm/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }