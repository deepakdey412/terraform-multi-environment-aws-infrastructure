# Terraform Backend Configuration
# This file creates the S3 bucket for storing Terraform state
# S3 now provides native state locking with versioning enabled

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Multi-Env-Infrastructure"
      ManagedBy   = "Terraform"
      Environment = "backend"
    }
  }
}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.backend_bucket_name

  tags = {
    Name        = "Terraform State Bucket"
    Description = "Stores Terraform state files for all environments"
  }
}

# Enable versioning for state file history and locking
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Variables
variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "backend_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

# Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_config_info" {
  description = "Backend configuration information"
  value = {
    bucket  = aws_s3_bucket.terraform_state.id
    region  = var.aws_region
    encrypt = true
    note    = "S3 versioning provides native state locking - DynamoDB not required"
  }
}
