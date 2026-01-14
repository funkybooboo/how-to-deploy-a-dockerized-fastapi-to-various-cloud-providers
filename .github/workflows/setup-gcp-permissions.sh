#!/bin/bash
PROJECT_ID="project-962d6846-0b6b-4745-b07"
SA="htdadftgcr@$PROJECT_ID.iam.gserviceaccount.com"

echo "Granting required roles to $SA in project $PROJECT_ID"

# Artifact Registry write access
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA" \
  --role="roles/artifactregistry.writer"

# Cloud Run Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA" \
  --role="roles/run.admin"

# Allow using other service accounts if needed
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SA" \
  --role="roles/iam.serviceAccountUser"

echo "All roles granted. The service account can now push to Artifact Registry and deploy to Cloud Run."

