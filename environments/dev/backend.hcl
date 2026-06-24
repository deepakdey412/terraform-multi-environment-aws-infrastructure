# Development Environment - Backend Configuration
# Use this file with: terraform init -backend-config=backend.hcl

bucket         = "YOUR-BACKEND-BUCKET-NAME"  # Replace with your backend bucket name
key            = "dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true
