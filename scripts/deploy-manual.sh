#!/bin/bash
# Manually deploy FastAPI application to Google Cloud Run
#
# This script builds a Docker image, pushes it to Artifact Registry,
# and deploys it to Cloud Run with production configuration.
#
# Prerequisites:
#   - Run ./scripts/setup-gcloud.sh first
#   - Docker must be running
#   - Authenticated with gcloud
#
# Usage: ./scripts/deploy-manual.sh [version-tag]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying FastAPI to Google Cloud Run${NC}\n"

# Load configuration if it exists
if [ -f .gcloud-config ]; then
    source .gcloud-config
    echo -e "${GREEN}✅ Loaded configuration from .gcloud-config${NC}"
else
    echo -e "${YELLOW}⚠️  No .gcloud-config found. Using defaults or prompting...${NC}"
fi

# Get project ID
PROJECT_ID=${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
    echo -e "${RED}❌ No project ID found${NC}"
    echo -e "${YELLOW}Run ./scripts/setup-gcloud.sh first or set GCP_PROJECT_ID${NC}"
    exit 1
fi

# Set defaults
REGION=${REGION:-"us-central1"}
REPOSITORY=${REPOSITORY:-"fastapi-repo"}
SERVICE_NAME="fastapi-service"
VERSION=${1:-"latest"}

# Construct image name
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/fastapi:${VERSION}"

echo -e "${BLUE}Configuration:${NC}"
echo -e "  Project ID:    ${PROJECT_ID}"
echo -e "  Region:        ${REGION}"
echo -e "  Service Name:  ${SERVICE_NAME}"
echo -e "  Image:         ${IMAGE}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo -e "${YELLOW}Please start Docker and try again${NC}"
    exit 1
fi

# Build Docker image
echo -e "${GREEN}🏗️  Building Docker image...${NC}"
docker build -f Dockerfile.prod -t "$IMAGE" .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker image built successfully${NC}"

# Also tag as latest if a specific version was provided
if [ "$VERSION" != "latest" ]; then
    LATEST_IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/fastapi:latest"
    docker tag "$IMAGE" "$LATEST_IMAGE"
    echo -e "${GREEN}✅ Tagged as latest${NC}"
fi

# Push to Artifact Registry
echo -e "\n${GREEN}📤 Pushing image to Artifact Registry...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

docker push "$IMAGE"

if [ "$VERSION" != "latest" ]; then
    docker push "$LATEST_IMAGE"
fi

echo -e "${GREEN}✅ Image pushed successfully${NC}"

# Deploy to Cloud Run
echo -e "\n${GREEN}🚀 Deploying to Cloud Run...${NC}"

gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE" \
    --region "$REGION" \
    --platform managed \
    --allow-unauthenticated \
    --port 8080 \
    --cpu 1 \
    --memory 512Mi \
    --min-instances 0 \
    --max-instances 10 \
    --concurrency 80 \
    --timeout 300 \
    --set-env-vars "ENVIRONMENT=production,DEBUG=false,LOG_LEVEL=INFO" \
    --quiet

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Deployment successful!${NC}"

# Get service URL
echo -e "\n${GREEN}🌐 Getting service URL...${NC}"
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region "$REGION" \
    --format 'value(status.url)')

echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "\n${GREEN}Service URL:${NC} ${YELLOW}${SERVICE_URL}${NC}\n"
echo -e "${GREEN}Test endpoints:${NC}"
echo -e "  Health:  ${YELLOW}${SERVICE_URL}/api/health${NC}"
echo -e "  Hello:   ${YELLOW}${SERVICE_URL}/api/hello${NC}"
echo -e "  Docs:    ${YELLOW}${SERVICE_URL}/api/docs${NC}"
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Test the deployment
echo -e "${GREEN}🧪 Testing deployment...${NC}"
sleep 5  # Wait for service to be fully ready

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${SERVICE_URL}/")

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Service is responding correctly!${NC}\n"
else
    echo -e "${YELLOW}⚠️  Service returned HTTP ${HTTP_CODE}${NC}"
    echo -e "${YELLOW}Check logs: gcloud run services logs tail ${SERVICE_NAME} --region ${REGION}${NC}\n"
fi
