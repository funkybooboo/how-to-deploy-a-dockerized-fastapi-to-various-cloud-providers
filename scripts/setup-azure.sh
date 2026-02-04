#!/bin/bash
# Setup Microsoft Azure environment for FastAPI deployment
#
# This script prepares your Azure subscription for deploying the FastAPI application.
# It creates required resources: Resource Group, Container Registry, and Container Apps Environment.
#
# Usage: ./scripts/setup-azure.sh

set -e  # Exit on error

# Source shared libraries
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/config.sh"

echo -e "${GREEN}🚀 Setting up Microsoft Azure environment for FastAPI deployment${NC}\n"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI not found${NC}"
    echo -e "${YELLOW}Please install it from: https://docs.microsoft.com/cli/azure/install-azure-cli${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI found${NC}"

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure${NC}"
    echo -e "${BLUE}Opening browser for login...${NC}"
    az login
else
    echo -e "${GREEN}✅ Already logged in to Azure${NC}"
fi

# Get current subscription
CURRENT_SUBSCRIPTION=$(az account show --query name --output tsv 2>/dev/null)

if [ -z "$CURRENT_SUBSCRIPTION" ]; then
    echo -e "${RED}❌ No subscription found${NC}"
    echo -e "${YELLOW}Please ensure you have an active Azure subscription${NC}"
    exit 1
fi

echo -e "${GREEN}Current subscription: ${CURRENT_SUBSCRIPTION}${NC}"
echo -e "${BLUE}Use this subscription? (y/n):${NC}"
read -r USE_CURRENT

if [[ ! "$USE_CURRENT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\n${BLUE}Available subscriptions:${NC}"
    az account list --output table
    echo -e "${BLUE}Enter subscription name or ID:${NC}"
    read -r SUBSCRIPTION
    az account set --subscription "$SUBSCRIPTION"
    CURRENT_SUBSCRIPTION=$(az account show --query name --output tsv)
    echo -e "${GREEN}Switched to: ${CURRENT_SUBSCRIPTION}${NC}"
fi

# Set default variables
RESOURCE_GROUP="fastapi-rg"
LOCATION="eastus"
ACR_NAME="fastapiregistry$(date +%s | tail -c 6)"  # Add random suffix for uniqueness
CONTAINER_APP_ENV="fastapi-env"

echo -e "\n${BLUE}Default configuration:${NC}"
echo -e "  Resource Group: ${RESOURCE_GROUP}"
echo -e "  Location:       ${LOCATION}"
echo -e "  ACR Name:       ${ACR_NAME}"
echo -e "  Environment:    ${CONTAINER_APP_ENV}"
echo ""
echo -e "${BLUE}Use these defaults? (y/n):${NC}"
read -r USE_DEFAULTS

if [[ ! "$USE_DEFAULTS" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}Enter Resource Group name (default: fastapi-rg):${NC}"
    read -r CUSTOM_RG
    if [ -n "$CUSTOM_RG" ]; then
        RESOURCE_GROUP="$CUSTOM_RG"
    fi

    echo -e "${BLUE}Enter Location (default: eastus):${NC}"
    echo -e "${YELLOW}Common locations: eastus, westus2, centralus, northeurope, westeurope${NC}"
    read -r CUSTOM_LOCATION
    if [ -n "$CUSTOM_LOCATION" ]; then
        LOCATION="$CUSTOM_LOCATION"
    fi

    echo -e "${BLUE}Enter ACR name (default: ${ACR_NAME}):${NC}"
    echo -e "${YELLOW}Must be globally unique, lowercase alphanumeric only${NC}"
    read -r CUSTOM_ACR
    if [ -n "$CUSTOM_ACR" ]; then
        ACR_NAME="$CUSTOM_ACR"
    fi
fi

# Validate ACR name
if ! az acr check-name --name "$ACR_NAME" --query nameAvailable --output tsv | grep -q "true"; then
    echo -e "${RED}❌ ACR name '${ACR_NAME}' is not available${NC}"
    echo -e "${YELLOW}Please run the script again and choose a different name${NC}"
    exit 1
fi

echo -e "\n${GREEN}📦 Creating Resource Group...${NC}"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

echo -e "${GREEN}✅ Resource Group created${NC}"

echo -e "\n${GREEN}📦 Creating Azure Container Registry...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Basic \
    --location "$LOCATION" \
    --admin-enabled true \
    --output none

echo -e "${GREEN}✅ Azure Container Registry created${NC}"

echo -e "\n${GREEN}🔐 Configuring Docker authentication...${NC}"
az acr login --name "$ACR_NAME"

echo -e "${GREEN}✅ Docker authentication configured${NC}"

echo -e "\n${GREEN}📦 Creating Container Apps Environment...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

# Check if containerapp extension is installed
if ! az extension show --name containerapp &> /dev/null; then
    echo -e "${BLUE}Installing Azure Container Apps extension...${NC}"
    az extension add --name containerapp --upgrade --yes
fi

az containerapp env create \
    --name "$CONTAINER_APP_ENV" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

echo -e "${GREEN}✅ Container Apps Environment created${NC}"

echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Build your Docker image"
echo -e "  2. Push to Azure Container Registry"
echo -e "  3. Deploy to Azure Container Apps"
echo -e "\n${YELLOW}Or run the automated deployment script:${NC}"
echo -e "  ${GREEN}./scripts/deploy-manual.sh${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Save configuration for other scripts
save_config ".azure-config" \
    "RESOURCE_GROUP=${RESOURCE_GROUP}" \
    "LOCATION=${LOCATION}" \
    "ACR_NAME=${ACR_NAME}" \
    "CONTAINER_APP_ENV=${CONTAINER_APP_ENV}"

echo -e "${GREEN}Configuration saved to .azure-config${NC}"

# Get ACR credentials for reference
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query loginServer --output tsv)

echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Configuration Summary:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Subscription:    ${CURRENT_SUBSCRIPTION}"
echo -e "  Resource Group:  ${RESOURCE_GROUP}"
echo -e "  Location:        ${LOCATION}"
echo -e "  ACR Name:        ${ACR_NAME}"
echo -e "  ACR Server:      ${ACR_LOGIN_SERVER}"
echo -e "  Environment:     ${CONTAINER_APP_ENV}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
