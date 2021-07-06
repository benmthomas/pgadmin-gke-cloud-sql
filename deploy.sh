#!/bin/bash
set -euo pipefail

# echo "Creating the database credentials..."
# kubectl apply -f ./kubernetes/gke/secret.yml

# Create the secret that includes the user/pass for postgres
echo 'Creating the postgres db secret'
POSTGRES_USER="$(cd terraform && terraform output --raw postgres_user)"
POSTGRES_PASS="$(cd terraform && terraform output --raw postgres_pass)"
kubectl create secret generic postgres-credentials \
  --from-literal=user="${POSTGRES_USER}" \
  --from-literal=password="${POSTGRES_PASS}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the configmap that includes the connection string for the DB.
echo 'Creating the postgresql connenction string Configmap'
POSTGRES_CONNECTION="$(cd terraform && terraform output --raw postgres_instance_connection_name)"
kubectl create configmap connectionname \
  --from-literal=connectionname="${POSTGRES_CONNECTION}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the service account
kubectl create serviceaccount postgres-ksa -n default \
  --dry-run=client -o yaml | kubectl apply -f -

# Annotate the KSA
GCP_SA="$(cd terraform && terraform output --raw gcp_serviceaccount)"
kubectl annotate serviceaccount -n default postgres-ksa --overwrite=true iam.gke.io/gcp-service-account="${GCP_SA}"

# echo "Creating the flask deployment and service..."

# kubectl apply -f ./kubernetes/gke/flask-deployment.yml
# kubectl apply -f ./kubernetes/gke/flask-service.yml


# echo "Adding the ingress..."

# # minikube addons enable ingress
# # kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
# kubectl apply -f ./kubernetes/minikube-ingress.yml


# echo "Creating the vue deployment and service..."

# kubectl apply -f ./kubernetes/gke/vue-deployment.yml
# kubectl apply -f ./kubernetes/gke/vue-service.yml

find kubernetes/gke/ -name "*.yml" | xargs -I{} kubectl apply -f {} \
--namespace default