# Deploy FastAPI to Google Cloud Run

This repository demonstrates how to deploy a Dockerized FastAPI application to **Google Cloud Run** using **GitHub Actions CI/CD**.  

It includes:

- `Dockerfile.prod` for building the production Docker image.
- `.github/workflows/cicd.yaml` workflow for GitHub Actions.
- Helper scripts to set up GCP permissions and resources.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [1. Service Account](#1-service-account)
  - [2. Enable APIs](#2-enable-apis)
  - [3. IAM Roles](#3-iam-roles)
  - [4. Artifact Registry Repository](#4-artifact-registry-repository)
- [CI/CD Workflow](#cicd-workflow)
- [Using this Repository for Another GCP Project](#using-this-repository-for-another-gcp-project)
- [Running the Setup Scripts](#running-the-setup-scripts)
- [License](#license)

---

## Prerequisites

1. A **Google Cloud Project**.  
2. A **service account** with a JSON key. This account will be used by GitHub Actions to deploy.  
3. GitHub repository with the **secret `GCP_SA_KEY`** containing your service account JSON.  
4. `gcloud` CLI installed locally for setup and verification.  

---

## Setup Instructions

### 1. Service Account

Create a service account in your GCP project:

```bash
gcloud iam service-accounts create fastapi-deployer \
    --display-name "FastAPI CI/CD deployer"
````

Download the JSON key and save it. Add it as a GitHub secret:

* **Secret name:** `GCP_SA_KEY`
* **Value:** Contents of the JSON key file.

---

### 2. Enable APIs

Manually enable the following APIs **once** for your project:

* [Cloud Run API](https://console.developers.google.com/apis/api/run.googleapis.com/overview)
* [Artifact Registry API](https://console.developers.google.com/apis/api/artifactregistry.googleapis.com/overview)
* [Cloud Build API](https://console.developers.google.com/apis/api/cloudbuild.googleapis.com/overview)

> Wait a few minutes after enabling for changes to propagate.

---

### 3. IAM Roles

Grant the service account the following roles:

```bash
PROJECT_ID="your-project-id"
SA_EMAIL="your-sa@your-project.iam.gserviceaccount.com"

# Artifact Registry writer
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/artifactregistry.writer"

# Cloud Run admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/run.admin"

# Allow using service accounts during deployment
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" \
  --role="roles/iam.serviceAccountUser"
```

You can also use the included helper scripts:

* `setup-gcp-permissions.sh` — grants required roles.
* `setup-gcp-ci.sh` — grants roles, ensures Artifact Registry repository exists, and checks required APIs.

---

### 4. Artifact Registry Repository

Ensure an Artifact Registry repository exists in the project:

```bash
gcloud artifacts repositories create custom-fastapi \
  --repository-format=docker \
  --location=us-central1 \
  --description="Docker repository for FastAPI images" \
  --project=$PROJECT_ID
```

> The `setup-gcp-ci.sh` script can also create this automatically if missing.

---

## CI/CD Workflow

The workflow in `.github/workflows/cicd.yaml` does the following:

1. Checks out the repository.
2. Authenticates to Google Cloud using the service account JSON.
3. Configures Docker for Artifact Registry.
4. Builds the Docker image for FastAPI.
5. Pushes the Docker image to Artifact Registry.
6. Deploys the image to Cloud Run.

> The workflow assumes the APIs are already enabled and the repository exists.

---

## Using this Repository for Another GCP Project

If someone wants to fork this repo and deploy to their own GCP project:

1. Create a service account in their project and download the JSON key.
2. Add it to their forked repository as `GCP_SA_KEY`.
3. Update `.github/workflows/cicd.yaml` with:

```yaml
env:
  PROJECT_ID: their-project-id
  SERVICE_NAME: desired-service-name
  REGION: their-region
  REPO_NAME: their-repo-name
  DOCKER_IMAGE_URL: us-central1-docker.pkg.dev/their-project-id/their-repo-name/their-service
```

4. Enable the required APIs in their project console.
5. Run the setup scripts or manually grant roles:

```bash
roles/artifactregistry.writer
roles/run.admin
roles/iam.serviceAccountUser
```

After that, pushing to `main` will trigger CI/CD and deploy automatically.

---

## Running the Setup Scripts

1. Make scripts executable:

```bash
chmod +x setup-gcp-ci.sh setup-gcp-permissions.sh
```

2. Run the setup scripts (with your **user account** that has Owner role):

```bash
./setup-gcp-ci.sh
# or for just permissions:
./setup-gcp-permissions.sh
```

> `setup-gcp-ci.sh` also checks if Artifact Registry repository exists and reports missing APIs.

