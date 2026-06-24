#!/bin/bash
# Deploy Script - Terraform Deployment Automation
# This script automates the Terraform deployment process

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

print_message "$BLUE" "=================================================="
print_message "$BLUE" "  Terraform Multi-Environment Deployment Script"
print_message "$BLUE" "=================================================="
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

print_message "$GREEN" "✅ Environment: ${ENVIRONMENT}"
print_message "$BLUE" "--------------------------------------------------"
echo ""

# Navigate to environment directory
cd "$ENV_DIR"

# Step 1: Terraform Init
print_message "$BLUE" "🔧 Step 1/5: Initializing Terraform..."
if terraform init -backend-config=backend.hcl; then
    print_message "$GREEN" "✅ Terraform initialization successful!"
else
    print_message "$RED" "❌ Terraform initialization failed!"
    exit 1
fi
echo ""

# Step 2: Terraform Format
print_message "$BLUE" "📝 Step 2/5: Formatting Terraform files..."
if terraform fmt -recursive; then
    print_message "$GREEN" "✅ Terraform formatting complete!"
else
    print_message "$YELLOW" "⚠️  Terraform formatting had issues (non-critical)"
fi
echo ""

# Step 3: Terraform Validate
print_message "$BLUE" "🔍 Step 3/5: Validating Terraform configuration..."
if terraform validate; then
    print_message "$GREEN" "✅ Terraform validation successful!"
else
    print_message "$RED" "❌ Terraform validation failed!"
    exit 1
fi
echo ""

# Step 4: Terraform Plan
print_message "$BLUE" "📋 Step 4/5: Creating Terraform execution plan..."
if terraform plan -out=tfplan; then
    print_message "$GREEN" "✅ Terraform plan created successfully!"
else
    print_message "$RED" "❌ Terraform plan failed!"
    exit 1
fi
echo ""

# Step 5: Terraform Apply
print_message "$YELLOW" "⚠️  Step 5/5: Applying Terraform changes..."
print_message "$YELLOW" "This will create/modify resources in AWS."
echo ""
read -p "Do you want to proceed with terraform apply? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    print_message "$BLUE" "🚀 Applying Terraform changes..."
    if terraform apply tfplan; then
        print_message "$GREEN" "✅ Terraform apply successful!"
        echo ""
        print_message "$GREEN" "=================================================="
        print_message "$GREEN" "  Deployment Complete! 🎉"
        print_message "$GREEN" "=================================================="
        echo ""
        print_message "$BLUE" "📊 Resource Outputs:"
        terraform output
    else
        print_message "$RED" "❌ Terraform apply failed!"
        exit 1
    fi
else
    print_message "$YELLOW" "⚠️  Deployment cancelled by user."
    print_message "$YELLOW" "Plan file 'tfplan' has been saved."
    print_message "$YELLOW" "You can apply it later with: terraform apply tfplan"
    exit 0
fi

# Cleanup plan file
rm -f tfplan

print_message "$GREEN" "✅ All operations completed successfully!"
