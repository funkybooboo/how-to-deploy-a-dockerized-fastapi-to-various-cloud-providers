#!/bin/bash
# Clean up Google Cloud resources
#
# This script removes all Cloud Run services and Artifact Registry resources
# created by this project to avoid ongoing charges.
#
# ⚠️  WARNING: This will permanently delete all deployed resources!
#
# Usage: ./scripts/cleanup.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}⚠️  Google Cloud Resource Cleanup${NC}\n"

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
    exit 1
fi

# Set defaults
REGION=${REGION:-"us-central1"}
REPOSITORY=${REPOSITORY:-"fastapi-repo"}
SERVICE_NAME="fastapi-service"

echo -e "${BLUE}Configuration:${NC}"
echo -e "  Project ID:    ${PROJECT_ID}"
echo -e "  Region:        ${REGION}"
echo -e "  Service Name:  ${SERVICE_NAME}"
echo -e "  Repository:    ${REPOSITORY}"
echo ""

echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
echo -e "${RED}WARNING: This will permanently delete:${NC}"
echo -e "${RED}  • Cloud Run service: ${SERVICE_NAME}${NC}"
echo -e "${RED}  • Artifact Registry repository: ${REPOSITORY}${NC}"
echo -e "${RED}  • All container images in the repository${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Are you sure you want to continue? (yes/no):${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${GREEN}❌ Cleanup cancelled${NC}"
    exit 0
fi

echo -e "\n${BLUE}Starting cleanup process...${NC}\n"

# Delete Cloud Run service
echo -e "${YELLOW}🗑️  Deleting Cloud Run service: ${SERVICE_NAME}${NC}"
if gcloud run services describe "$SERVICE_NAME" --region "$REGION" &> /dev/null; then
    gcloud run services delete "$SERVICE_NAME" \
        --region "$REGION" \
        --quiet
    echo -e "${GREEN}✅ Cloud Run service deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Service not found, skipping...${NC}"
fi

# Delete Artifact Registry repository
echo -e "\n${YELLOW}🗑️  Deleting Artifact Registry repository: ${REPOSITORY}${NC}"
if gcloud artifacts repositories describe "$REPOSITORY" --location "$REGION" &> /dev/null; then
    gcloud artifacts repositories delete "$REPOSITORY" \
        --location "$REGION" \
        --quiet
    echo -e "${GREEN}✅ Artifact Registry repository deleted${NC}"
else
    echo -e "${YELLOW}⚠️  Repository not found, skipping...${NC}"
fi

# Remove local configuration file
if [ -f .gcloud-config ]; then
    rm .gcloud-config
    echo -e "${GREEN}✅ Local configuration file removed${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${GREEN}All resources have been deleted.${NC}"
echo -e "${YELLOW}Note: APIs remain enabled but don't incur charges unless used.${NC}\n"

echo -e "${BLUE}To verify deletion:${NC}"
echo -e "  Cloud Run:    ${YELLOW}gcloud run services list --region ${REGION}${NC}"
echo -e "  Registries:   ${YELLOW}gcloud artifacts repositories list --location ${REGION}${NC}\n"
