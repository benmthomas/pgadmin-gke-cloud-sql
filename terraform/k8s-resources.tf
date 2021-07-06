# data "terraform_remote_state" "gke" {
#   backend = "local"

#   config = {
#     path = "../terraform/terraform.tfstate"
#   }
# }

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

# data "google_container_cluster" "primary" {
# #   name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
#   name = "${var.project_id}-gke"
#   location = var.zone
# }

provider "kubernetes" {
#   load_config_file = false
  host     = "https://${google_container_cluster.primary.endpoint}"
# host  = "https://${data.google_container_cluster.primary.endpoint}"
#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = "${google_container_cluster.primary.master_auth.0.client_key}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
#   host = "https://${data.terraform_remote_state.gke.outputs.kubernetes_cluster_host}"

  token                  = "${data.google_client_config.default.access_token}"
#   cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)

}

# resource "kubernetes_manifest" "vue-deployment" {
#   provider = kubernetes-alpha
#   manifest = {
#     "apiVersion" = "apps/v1"
#     "kind" = "Deployment"
#     "metadata" = {
#         "creationTimestamp" = null
#         "labels" = {
#         "name" = "vue"
#         }
#         "name" = "vue"
#         "namespace" = "default"
#     }
#     "spec" = {
#         "replicas" = 1
#         "selector" = {
#         "matchLabels" = {
#             "app" = "vue"
#         }
#       }
#         "template" = {
#         "metadata" = {
#             "creationTimestamp" = null
#             "labels" = {
#             "app" = "vue"
#             }
#         }
#         "spec" = {
#             "containers" = [
#             {
#                 "image" = "mjhea0/vue-kubernetes:latest"
#                 "imagePullPolicy" = "Always"
#                 "name" = "vue"
#                 "resources" = {}
#                 "terminationMessagePath" = "/dev/termination-log"
#                 "terminationMessagePolicy" = "File"
#             },
#             ]
#             "restartPolicy" = "Always"
#             "terminationGracePeriodSeconds" = 30
#         }
#       }
#     }
#   }
# }

resource "kubernetes_namespace" "test" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "test" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}