# Staging Environment - Main Configuration
# This orchestrates all modules for the stage environment

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration provided via backend config file
    # Run: terraform init -backend-config=backend.hcl
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    }
  }
}

# Local variables
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_count = var.public_subnet_count
  enable_flow_logs    = false
  common_tags         = local.common_tags
}

# Security Group Module
module "security_group" {
  source = "../../modules/security-group"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "ec2-sg"
  sg_description = "Security group for EC2 instances in ${var.environment} environment"

  ingress_rules = [
    {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidr
    },
    {
      description = "HTTP access"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HTTPS access"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  common_tags = local.common_tags
}

# S3 Module - Application Bucket
module "s3_app" {
  source = "../../modules/s3"

  bucket_name             = "${var.project_name}-${var.environment}-app-${data.aws_caller_identity.current.account_id}"
  environment             = var.environment
  enable_versioning       = true
  enable_lifecycle_rules  = true
  common_tags             = local.common_tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  project_name   = var.project_name
  environment    = var.environment
  s3_bucket_arns = [module.s3_app.bucket_arn]
  common_tags    = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name               = var.project_name
  environment                = var.environment
  instance_count             = var.instance_count
  instance_type              = var.instance_type
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.security_group.security_group_id]
  iam_instance_profile       = module.iam.instance_profile_name
  user_data_script           = templatefile("${path.module}/user-data.sh", {
    environment    = var.environment
    s3_bucket_name = module.s3_app.bucket_id
    log_group_name = module.cloudwatch.log_group_name
  })
  enable_detailed_monitoring = false
  root_volume_size           = 8
  allocate_eip               = false
  common_tags                = local.common_tags
}

# CloudWatch Module
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  log_retention_days = 14
  instance_ids       = module.ec2.instance_ids
  create_alarms      = false
  common_tags        = local.common_tags
}

# Data source for AWS account ID
data "aws_caller_identity" "current" {}
