#!/bin/bash
# Setup Google Cloud environment for FastAPI deployment
#
# This script prepares your Google Cloud project for deploying the FastAPI application.
# It enables required APIs, creates an Artifact Registry repository, and configures Docker authentication.
#
# Usage: ./scripts/setup-gcloud.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setting up Google Cloud environment for FastAPI deployment${NC}\n"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI not found${NC}"
    echo -e "${YELLOW}Please install it from: https://cloud.google.com/sdk/docs/install${NC}"
    exit 1
fi

echo -e "${GREEN}✅ gcloud CLI found${NC}"

# Get current project ID or prompt for one
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [ -z "$CURRENT_PROJECT" ] || [ "$CURRENT_PROJECT" = "(unset)" ]; then
    echo -e "\n${YELLOW}No project currently set.${NC}"
    echo -e "${BLUE}Enter your GCP Project ID:${NC}"
    read -r PROJECT_ID

    if [ -z "$PROJECT_ID" ]; then
        echo -e "${RED}❌ Project ID cannot be empty${NC}"
        exit 1
    fi

    gcloud config set project "$PROJECT_ID"
else
    echo -e "${GREEN}Current project: ${CURRENT_PROJECT}${NC}"
    echo -e "${BLUE}Use this project? (y/n):${NC}"
    read -r USE_CURRENT

    if [[ ! "$USE_CURRENT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${BLUE}Enter your GCP Project ID:${NC}"
        read -r PROJECT_ID
        gcloud config set project "$PROJECT_ID"
    else
        PROJECT_ID="$CURRENT_PROJECT"
    fi
fi

echo -e "\n${GREEN}📦 Enabling required Google Cloud APIs...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

# Enable required APIs
gcloud services enable run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com

echo -e "${GREEN}✅ APIs enabled${NC}"

# Set default region
REGION="us-central1"
echo -e "\n${BLUE}Default region will be set to: ${REGION}${NC}"
echo -e "${BLUE}Change region? (y/n):${NC}"
read -r CHANGE_REGION

if [[ "$CHANGE_REGION" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}Enter your preferred region (e.g., us-central1, europe-west1):${NC}"
    read -r REGION
fi

# Create Artifact Registry repository
echo -e "\n${GREEN}📦 Creating Artifact Registry repository...${NC}"
REPO_NAME="fastapi-repo"

gcloud artifacts repositories create "$REPO_NAME" \
    --repository-format=docker \
    --location="$REGION" \
    --description="FastAPI Docker repository for Cloud Run deployment" \
    2>/dev/null || echo -e "${YELLOW}⚠️  Repository may already exist, continuing...${NC}"

echo -e "${GREEN}✅ Artifact Registry repository ready${NC}"

# Configure Docker authentication
echo -e "\n${GREEN}🔐 Configuring Docker authentication...${NC}"
gcloud auth configure-docker "${REGION}-docker.pkg.dev"

echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Build your Docker image"
echo -e "  2. Push to Artifact Registry"
echo -e "  3. Deploy to Cloud Run"
echo -e "\n${YELLOW}Or run the automated deployment script:${NC}"
echo -e "  ${GREEN}./scripts/deploy-manual.sh${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Save configuration for other scripts
cat > .gcloud-config << EOF
PROJECT_ID=${PROJECT_ID}
REGION=${REGION}
REPOSITORY=${REPO_NAME}
EOF

echo -e "${GREEN}Configuration saved to .gcloud-config${NC}"
