#!/bin/bash
# Format Script - Terraform Code Formatting
# This script formats all Terraform files

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
print_message "$BLUE" "  Terraform Code Formatting"
print_message "$BLUE" "=================================================="
echo ""

# Format all Terraform files recursively
print_message "$YELLOW" "📝 Formatting Terraform files..."
echo ""

if terraform fmt -recursive -diff; then
    print_message "$GREEN" "✅ All Terraform files formatted successfully!"
    echo ""
    print_message "$GREEN" "=================================================="
    print_message "$GREEN" "  Formatting Complete!"
    print_message "$GREEN" "=================================================="
else
    print_message "$RED" "❌ Formatting encountered errors!"
    exit 1
fi

# Check if any files were changed
if [ -n "$(terraform fmt -recursive -check 2>&1)" ]; then
    print_message "$YELLOW" "⚠️  Some files were modified during formatting."
    print_message "$YELLOW" "Please review the changes and commit them."
else
    print_message "$GREEN" "✅ No formatting changes needed. All files are properly formatted!"
fi
