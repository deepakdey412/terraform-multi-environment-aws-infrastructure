# Staging Environment - Backend Configuration
# Use this file with: terraform init -backend-config=backend.hcl
# S3 versioning provides native state locking - DynamoDB not required

bucket  = "terraform-state-940507691983"
key     = "stage/terraform.tfstate"
region  = "us-east-1"
encrypt = true
