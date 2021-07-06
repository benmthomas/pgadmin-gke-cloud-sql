#!/bin/bash

###############################################################################
#
# Apply the configmap, secret, and deployment manifests to the cluster.
#
###############################################################################

set -euo pipefail
set -o nounset
set -o pipefail

# Create the database credentials
# kubectl apply -f ./kubernetes/gke/secret.yml

# Create the secret that includes the user/pass of postgres instance
echo 'Creating the postgres db secret'
POSTGRES_USER="$(cd terraform && terraform output --raw postgres_user)"
POSTGRES_PASS="$(cd terraform && terraform output --raw postgres_pass)"
kubectl create secret generic postgres-credentials \
  --from-literal=user="${POSTGRES_USER}" \
  --from-literal=password="${POSTGRES_PASS}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the configmap that includes the connection string to the postgres instance.
echo 'Creating the postgresql connenction string Configmap'
POSTGRES_CONNECTION="$(cd terraform && terraform output --raw postgres_instance_connection_name)"
kubectl create configmap connectionname \
  --from-literal=connectionname="${POSTGRES_CONNECTION}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create the K8s Service Account (KSA)
kubectl create serviceaccount postgres-ksa -n default \
  --dry-run=client -o yaml | kubectl apply -f -

# Annotate the KSA
GCP_SA="$(cd terraform && terraform output --raw gcp_serviceaccount)"
kubectl annotate serviceaccount -n default postgres-ksa --overwrite=true iam.gke.io/gcp-service-account="${GCP_SA}"

# Apply k8s manifests
find kubernetes/gke/ -name "*.yml" | xargs -I{} kubectl apply -f {} \
--namespace default