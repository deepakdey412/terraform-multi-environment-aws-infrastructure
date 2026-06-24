#!/bin/bash
# Switch Environment Script - Interactive Environment Switcher
# This script helps switch between different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to display banner
display_banner() {
    clear
    print_message "$CYAN" "=================================================="
    print_message "$CYAN" "  Multi-Environment Infrastructure Manager"
    print_message "$CYAN" "=================================================="
    echo ""
}

# Function to display current environment info
display_env_info() {
    local env=$1
    local env_dir="environments/${env}"
    
    print_message "$BLUE" "📊 Environment Information: ${env}"
    print_message "$BLUE" "--------------------------------------------------"
    
    if [ -d "$env_dir" ]; then
        cd "$env_dir"
        
        # Initialize if needed
        if [ ! -d ".terraform" ]; then
            print_message "$YELLOW" "Environment not initialized. Initializing..."
            terraform init -backend-config=backend.hcl > /dev/null 2>&1 || true
        fi
        
        # Show state information
        if [ -f ".terraform/terraform.tfstate" ] || terraform state list > /dev/null 2>&1; then
            print_message "$GREEN" "✅ State: Initialized"
            
            # Count resources
            RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l || echo "0")
            print_message "$BLUE" "📦 Resources: ${RESOURCE_COUNT}"
            
            # Show outputs if available
            if [ "$RESOURCE_COUNT" -gt 0 ]; then
                print_message "$BLUE" "📋 Recent Outputs:"
                terraform output 2>/dev/null | head -5 || print_message "$YELLOW" "No outputs available"
            fi
        else
            print_message "$YELLOW" "⚠️  State: Not deployed"
        fi
        
        cd ../..
    else
        print_message "$RED" "❌ Environment directory not found!"
    fi
    echo ""
}

# Function to display menu
display_menu() {
    print_message "$YELLOW" "Select an environment:"
    echo ""
    print_message "$GREEN" "  1) Development (dev)"
    print_message "$YELLOW" "  2) Staging (stage)"
    print_message "$CYAN" "  3) Production (prod)"
    echo ""
    print_message "$BLUE" "  4) View all environments status"
    print_message "$RED" "  5) Exit"
    echo ""
}

# Function to show all environments status
show_all_status() {
    display_banner
    print_message "$BLUE" "📊 All Environments Status"
    print_message "$BLUE" "=================================================="
    echo ""
    
    for env in dev stage prod; do
        display_env_info "$env"
    done
    
    read -p "Press Enter to continue..."
}

# Function to handle environment selection
handle_selection() {
    local choice=$1
    local env=""
    
    case $choice in
        1)
            env="dev"
            ;;
        2)
            env="stage"
            ;;
        3)
            env="prod"
            ;;
        4)
            show_all_status
            return
            ;;
        5)
            print_message "$GREEN" "Goodbye! 👋"
            exit 0
            ;;
        *)
            print_message "$RED" "❌ Invalid selection!"
            sleep 2
            return
            ;;
    esac
    
    # Display selected environment info
    display_banner
    display_env_info "$env"
    
    # Show action menu
    print_message "$YELLOW" "What would you like to do?"
    echo ""
    print_message "$GREEN" "  1) Deploy/Update infrastructure"
    print_message "$BLUE" "  2) View outputs"
    print_message "$YELLOW" "  3) Validate configuration"
    print_message "$CYAN" "  4) View state"
    print_message "$RED" "  5) Destroy infrastructure"
    print_message "$BLUE" "  6) Back to main menu"
    echo ""
    read -p "Enter your choice [1-6]: " action
    
    case $action in
        1)
            print_message "$BLUE" "🚀 Deploying to ${env}..."
            bash scripts/deploy.sh "$env"
            ;;
        2)
            cd "environments/${env}"
            terraform output
            cd ../..
            ;;
        3)
            bash scripts/validate.sh "$env"
            ;;
        4)
            cd "environments/${env}"
            terraform state list
            cd ../..
            ;;
        5)
            bash scripts/destroy.sh "$env"
            ;;
        6)
            return
            ;;
        *)
            print_message "$RED" "❌ Invalid action!"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    display_banner
    display_menu
    read -p "Enter your choice [1-5]: " choice
    handle_selection "$choice"
done
