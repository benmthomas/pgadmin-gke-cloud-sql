# Deploy a 3-tier Architecture Bookshelf App on GKE using Terraform

## Acknowledgement

This project is built on top of this [repo](https://github.com/testdrivenio/flask-vue-kubernetes).

## Prerequisites

### Google Cloud Project

 You'll need access to a Google Cloud Project with billing enabled. See [Creating and Managing Projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects) for creating a new project. To make cleanup easier it's recommended to create a new project.

### Required GCP APIs

The following APIs will be enabled by terraform code:

* Compute Engine API
* Kubernetes Engine API
* Cloud SQL Admin API
* Secret Token API
* Stackdriver Logging API
* Stackdriver Monitoring API
* IAM Service Account Credentials API

### Tools

The following tools are required:

* Access to an existing Google Cloud project.
* Bash or Shell common command line tool.
* [Terraform v0.13.0+](https://www.terraform.io/downloads.html)
* [gcloud v255.0.0+](https://cloud.google.com/sdk/downloads)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) that matches the latest generally-available GKE cluster version.

# Deployment

### Authenticate gcloud

 Authenticate your gcloud client by running the following command:

```console
gcloud auth login
```

### Configure gcloud settings

Run `gcloud config list` and make sure that `compute/zone`, `compute/region` and `core/project` are populated with appropriate values. You can set their values with the following commands:

```console
# Where the region is us-central1
gcloud config set compute/region us-central1

Updated property [compute/region].
```

```console
# Where the zone inside the region is us-central1-b
gcloud config set compute/zone us-central1-b

Updated property [compute/zone].
```

```console
# Where the project name is my-project-name
gcloud config set project my-project-name

Updated property [core/project].
```

## Set terraform variables

If you wish to override the terraform variables, update the `terraform/terraform.tfvars` file with the desired value.
E.g.
```terraform
project_id = "my-project-id"
region     = "us-central1"
zone       = "us-central1-b"
```

## Create Resources

To create the entire environment via Terraform, run the following command from the project root folder:

```bash
sh ./create.sh
```

Next, to deploy the application by applying the k8s manifests located in the `/kubernetes/gke` directory:

```bash
sh ./deploy.sh
```

## Tear Down

To delete all created resources in GCP, run:

```bash
sh ./destroy.sh
```