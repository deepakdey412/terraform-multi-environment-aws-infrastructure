#!/bin/bash
# Validate Script - Terraform Validation
# This script validates Terraform configurations

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
print_message "$BLUE" "  Terraform Configuration Validation"
print_message "$BLUE" "=================================================="
echo ""

# Check if environment is provided
if [ -z "$1" ]; then
    print_message "$YELLOW" "No environment specified. Validating all environments..."
    ENVIRONMENTS=("dev" "stage" "prod")
else
    ENVIRONMENT=$1
    ENV_DIR="environments/${ENVIRONMENT}"
    
    # Validate environment
    if [ ! -d "$ENV_DIR" ]; then
        print_message "$RED" "❌ Error: Environment '${ENVIRONMENT}' does not exist!"
        print_message "$YELLOW" "Available environments: dev, stage, prod"
        exit 1
    fi
    
    ENVIRONMENTS=("$ENVIRONMENT")
fi

VALIDATION_FAILED=0

# Validate each environment
for env in "${ENVIRONMENTS[@]}"; do
    ENV_DIR="environments/${env}"
    
    print_message "$BLUE" "🔍 Validating environment: ${env}"
    print_message "$BLUE" "--------------------------------------------------"
    
    cd "$ENV_DIR"
    
    # Initialize Terraform
    print_message "$YELLOW" "Initializing Terraform..."
    if terraform init -backend=false > /dev/null 2>&1; then
        print_message "$GREEN" "✅ Initialization successful"
    else
        print_message "$RED" "❌ Initialization failed"
        VALIDATION_FAILED=1
        cd ../..
        echo ""
        continue
    fi
    
    # Validate configuration
    print_message "$YELLOW" "Validating configuration..."
    if terraform validate; then
        print_message "$GREEN" "✅ Validation successful for ${env}!"
    else
        print_message "$RED" "❌ Validation failed for ${env}!"
        VALIDATION_FAILED=1
    fi
    
    cd ../..
    echo ""
done

# Summary
print_message "$BLUE" "=================================================="
if [ $VALIDATION_FAILED -eq 0 ]; then
    print_message "$GREEN" "✅ All validations passed!"
    print_message "$BLUE" "=================================================="
    exit 0
else
    print_message "$RED" "❌ Some validations failed!"
    print_message "$BLUE" "=================================================="
    exit 1
fi
