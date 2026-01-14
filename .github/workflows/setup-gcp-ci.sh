#!/bin/bash

# ================================
# Configuration
# ================================
PROJECT_ID="project-962d6846-0b6b-4745-b07"
SA="htdadftgcr@$PROJECT_ID.iam.gserviceaccount.com"
REGION="us-central1"
REPO_NAME="custom-fastapi"
APIS=(run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com)

# ================================
# 1. Check required APIs
# ================================
echo "Checking required APIs..."
for api in "${APIS[@]}"; do
    status=$(gcloud services list --enabled --project="$PROJECT_ID" --filter="service:$api" --format="value(service)")
    if [ "$status" != "$api" ]; then
        echo "API $api is NOT enabled. Please enable it in console: https://console.developers.google.com/apis/api/$api/overview?project=$PROJECT_ID"
    else
        echo "API $api is enabled."
    fi
done

# ================================
# 2. Ensure Artifact Registry repository exists
# ================================
echo "Checking Artifact Registry repository '$REPO_NAME'..."
if ! gcloud artifacts repositories list --location="$REGION" --project="$PROJECT_ID" | grep -q "^$REPO_NAME "; then
    echo "Repository '$REPO_NAME' not found. Creating..."
    gcloud artifacts repositories create "$REPO_NAME" \
        --repository-format=docker \
        --location="$REGION" \
        --description="Docker repository for FastAPI images" \
        --project="$PROJECT_ID"
else
    echo "Repository '$REPO_NAME' already exists."
fi

# ================================
# 3. Grant required IAM roles to the service account
# ================================
echo "Granting required roles to $SA..."

declare -A ROLES
ROLES=(
    ["roles/artifactregistry.writer"]="Allows pushing images to Artifact Registry"
    ["roles/run.admin"]="Allows deploying and managing Cloud Run services"
    ["roles/iam.serviceAccountUser"]="Allows using service accounts during deployment"
)

for role in "${!ROLES[@]}"; do
    echo "Granting $role (${ROLES[$role]})..."
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SA" \
        --role="$role"
done

echo "Setup complete. Your service account should now be able to push Docker images and deploy to Cloud Run."

