#!/bin/bash
# Shared color codes for terminal output
# Source this file in your scripts: source "$(dirname "$0")/lib/colors.sh"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Export for use in sourcing scripts
export RED GREEN YELLOW BLUE NC
