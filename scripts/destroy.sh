#!/bin/bash
# Destroy Script - Terraform Destroy Automation
# This script automates the Terraform destroy process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message "$RED" "=================================================="
print_message "$RED" "  Terraform Infrastructure Destroy Script"
print_message "$RED" "=================================================="
echo ""

# Check if environment is provided
if [ -z "$1" ]; then
    print_message "$RED" "❌ Error: Environment not specified!"
    echo ""
    print_message "$YELLOW" "Usage: $0 <environment>"
    print_message "$YELLOW" "Example: $0 dev"
    echo ""
    print_message "$YELLOW" "Available environments: dev, stage, prod"
    exit 1
fi

ENVIRONMENT=$1
ENV_DIR="environments/${ENVIRONMENT}"

# Validate environment
if [ ! -d "$ENV_DIR" ]; then
    print_message "$RED" "❌ Error: Environment '${ENVIRONMENT}' does not exist!"
    print_message "$YELLOW" "Available environments: dev, stage, prod"
    exit 1
fi

print_message "$YELLOW" "⚠️  Environment: ${ENVIRONMENT}"
print_message "$RED" "--------------------------------------------------"
echo ""

print_message "$RED" "⚠️  WARNING: This will DESTROY all resources in the ${ENVIRONMENT} environment!"
print_message "$RED" "⚠️  This action cannot be undone!"
echo ""

# Double confirmation for production
if [ "$ENVIRONMENT" = "prod" ]; then
    print_message "$RED" "🚨 CRITICAL: You are about to destroy PRODUCTION environment!"
    read -p "Type 'destroy-production' to confirm: " first_confirm
    
    if [ "$first_confirm" != "destroy-production" ]; then
        print_message "$GREEN" "✅ Destruction cancelled. No changes made."
        exit 0
    fi
fi

read -p "Are you absolutely sure you want to destroy ${ENVIRONMENT}? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    print_message "$GREEN" "✅ Destruction cancelled. No changes made."
    exit 0
fi

# Navigate to environment directory
cd "$ENV_DIR"

# Step 1: Terraform Init
print_message "$BLUE" "🔧 Step 1/2: Initializing Terraform..."
if terraform init -backend-config=backend.hcl; then
    print_message "$GREEN" "✅ Terraform initialization successful!"
else
    print_message "$RED" "❌ Terraform initialization failed!"
    exit 1
fi
echo ""

# Step 2: Terraform Destroy
print_message "$RED" "💥 Step 2/2: Destroying infrastructure..."
if terraform destroy -auto-approve; then
    print_message "$GREEN" "✅ Infrastructure destroyed successfully!"
    echo ""
    print_message "$GREEN" "=================================================="
    print_message "$GREEN" "  Destruction Complete!"
    print_message "$GREEN" "=================================================="
else
    print_message "$RED" "❌ Terraform destroy failed!"
    print_message "$YELLOW" "Some resources may still exist. Please check AWS Console."
    exit 1
fi

print_message "$YELLOW" "⚠️  Remember to verify all resources are deleted in AWS Console."
