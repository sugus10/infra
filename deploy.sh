#!/bin/bash

# EKS Infrastructure Deployment Script
# This script helps deploy infrastructure to different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <environment> <action> [options]"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment"
    echo "  prod      - Production environment"
    echo ""
    echo "Actions:"
    echo "  init      - Initialize Terraform"
    echo "  plan      - Plan infrastructure changes"
    echo "  apply     - Apply infrastructure changes"
    echo "  destroy   - Destroy infrastructure"
    echo "  output    - Show infrastructure outputs"
    echo "  validate  - Validate Terraform configuration"
    echo ""
    echo "Options:"
    echo "  --auto-approve    - Skip confirmation prompts"
    echo "  --help           - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev init"
    echo "  $0 staging plan"
    echo "  $0 prod apply --auto-approve"
    echo "  $0 dev destroy --auto-approve"
}

# Function to validate environment
validate_environment() {
    local env=$1
    case $env in
        dev|staging|prod)
            return 0
            ;;
        *)
            print_error "Invalid environment: $env"
            echo "Valid environments: dev, staging, prod"
            exit 1
            ;;
    esac
}

# Function to validate action
validate_action() {
    local action=$1
    case $action in
        init|plan|apply|destroy|output|validate)
            return 0
            ;;
        *)
            print_error "Invalid action: $action"
            echo "Valid actions: init, plan, apply, destroy, output, validate"
            exit 1
            ;;
    esac
}

# Function to check if environment directory exists
check_environment_exists() {
    local env=$1
    if [ ! -d "environments/$env" ]; then
        print_error "Environment directory not found: environments/$env"
        exit 1
    fi
}

# Function to run terraform command
run_terraform() {
    local env=$1
    local action=$2
    local auto_approve=$3
    
    cd "environments/$env"
    
    case $action in
        init)
            print_status "Initializing Terraform for $env environment..."
            terraform init
            ;;
        plan)
            print_status "Planning infrastructure changes for $env environment..."
            terraform plan
            ;;
        apply)
            print_status "Applying infrastructure changes for $env environment..."
            if [ "$auto_approve" = "true" ]; then
                terraform apply -auto-approve
            else
                terraform apply
            fi
            ;;
        destroy)
            print_warning "This will destroy all infrastructure in $env environment!"
            if [ "$auto_approve" = "true" ]; then
                terraform destroy -auto-approve
            else
                read -p "Are you sure you want to destroy $env environment? (yes/no): " confirm
                if [ "$confirm" = "yes" ]; then
                    terraform destroy
                else
                    print_status "Destroy cancelled."
                    exit 0
                fi
            fi
            ;;
        output)
            print_status "Showing infrastructure outputs for $env environment..."
            terraform output
            ;;
        validate)
            print_status "Validating Terraform configuration for $env environment..."
            terraform validate
            ;;
    esac
    
    cd - > /dev/null
}

# Main script
main() {
    # Check if at least 2 arguments are provided
    if [ $# -lt 2 ]; then
        print_error "Missing required arguments"
        show_usage
        exit 1
    fi
    
    local environment=$1
    local action=$2
    local auto_approve="false"
    
    # Parse additional arguments
    shift 2
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto-approve)
                auto_approve="true"
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate inputs
    validate_environment "$environment"
    validate_action "$action"
    check_environment_exists "$environment"
    
    # Show configuration
    print_status "Environment: $environment"
    print_status "Action: $action"
    print_status "Auto-approve: $auto_approve"
    echo ""
    
    # Run terraform command
    run_terraform "$environment" "$action" "$auto_approve"
    
    if [ $? -eq 0 ]; then
        print_success "Operation completed successfully!"
    else
        print_error "Operation failed!"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
