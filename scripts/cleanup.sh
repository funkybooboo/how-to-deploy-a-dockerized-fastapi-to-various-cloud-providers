#!/bin/bash
# Cleanup Azure resources for FastAPI deployment
#
# This script removes all Azure resources created for the FastAPI deployment.
# Use this to avoid ongoing charges when you're done with the project.
#
# WARNING: This will delete all resources in the resource group!
#
# Usage: ./scripts/cleanup.sh [--confirm]

# Source shared libraries
SCRIPT_DIR="$(dirname "$0")"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/config.sh"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🧹 Azure Resource Cleanup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Load configuration if it exists
if load_config ".azure-config"; then
    echo -e "${GREEN}✅ Loaded configuration from .azure-config${NC}"
else
    echo -e "${YELLOW}⚠️  No .azure-config found. Using default resource group name.${NC}"
    RESOURCE_GROUP="fastapi-rg"
fi

echo -e "\n${YELLOW}This will delete the following resources:${NC}"
echo -e "  - Resource Group: ${RED}${RESOURCE_GROUP}${NC}"
echo -e "  - All resources within this group:"

# List resources in the resource group
if az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
    echo ""
    az resource list --resource-group "$RESOURCE_GROUP" --output table 2>/dev/null || echo -e "${YELLOW}    (Unable to list resources)${NC}"
    echo ""
else
    echo -e "\n${YELLOW}⚠️  Resource group '${RESOURCE_GROUP}' does not exist.${NC}"
    echo -e "${YELLOW}Nothing to clean up!${NC}\n"
    exit 0
fi

# Estimate costs
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Cost Impact:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  If you delete now, you'll stop paying for:"
echo -e "    • Container Apps (~$0.03/hour per replica when running)"
echo -e "    • Container Registry (~$5/month for Basic SKU)"
echo -e "    • Storage costs (~$0.10/GB/month)"
echo -e ""
echo -e "  ${GREEN}Recommended:${NC} Delete when done learning/testing"
echo -e "  ${YELLOW}Keep if:${NC} You need this deployment for production use"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Confirmation
if [ "$1" != "--confirm" ]; then
    echo -e "${RED}⚠️  WARNING: This action cannot be undone!${NC}\n"
    echo -e "${YELLOW}Are you sure you want to delete all resources in '${RESOURCE_GROUP}'?${NC}"
    echo -e "${BLUE}Type 'yes' to confirm:${NC}"
    read -r CONFIRMATION

    if [ "$CONFIRMATION" != "yes" ]; then
        echo -e "\n${GREEN}✅ Cleanup cancelled. No resources were deleted.${NC}\n"
        exit 0
    fi
fi

echo -e "\n${GREEN}🗑️  Deleting resource group '${RESOURCE_GROUP}'...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}\n"

# Delete resource group (this deletes all resources within it)
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes \
    --no-wait

echo -e "${GREEN}✅ Deletion initiated!${NC}"
echo -e "${YELLOW}The deletion is running in the background and may take 5-10 minutes to complete.${NC}\n"

# Verify deletion status
echo -e "${BLUE}To check deletion status, run:${NC}"
echo -e "  ${YELLOW}az group exists --name ${RESOURCE_GROUP}${NC}"
echo -e ""
echo -e "${BLUE}To wait for deletion to complete, run:${NC}"
echo -e "  ${YELLOW}az group wait --name ${RESOURCE_GROUP} --deleted${NC}\n"

# Clean up local configuration file
if [ -f .azure-config ]; then
    echo -e "${GREEN}🗑️  Removing local configuration file...${NC}"
    rm -f .azure-config
    echo -e "${GREEN}✅ Local configuration removed${NC}\n"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Cleanup Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Resource Group: ${RED}${RESOURCE_GROUP}${NC} (deletion initiated)"
echo -e "  Status:         ${YELLOW}Deleting in background${NC}"
echo -e "  Time:           ${YELLOW}~5-10 minutes${NC}"
echo -e "  Cost Impact:    ${GREEN}Charges will stop once deletion completes${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${GREEN}✅ Cleanup script completed!${NC}"
echo -e "${YELLOW}Note: The actual deletion is still in progress.${NC}\n"

# Optionally wait for deletion (commented out by default)
# Uncomment if you want the script to wait for deletion to complete:
# echo -e "${YELLOW}Waiting for deletion to complete...${NC}"
# az group wait --name "$RESOURCE_GROUP" --deleted --timeout 600
# echo -e "${GREEN}✅ Resource group fully deleted!${NC}\n"

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}What's Next?${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  • Verify deletion:   ${YELLOW}az group exists --name ${RESOURCE_GROUP}${NC}"
echo -e "  • Check costs:       ${YELLOW}Azure Portal → Cost Management${NC}"
echo -e "  • Redeploy later:    ${YELLOW}./scripts/setup-azure.sh${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"
