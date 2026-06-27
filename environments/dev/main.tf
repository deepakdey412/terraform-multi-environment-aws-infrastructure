# Development Environment - Main Configuration
# Architecture: Public Subnet (Bastion, NAT, ALB) + Private Subnet (App EC2 with ASG)

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

# VPC Module - Creates Public and Private Subnets with NAT Gateway
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  enable_nat_gateway   = var.enable_nat_gateway
  enable_flow_logs     = false
  common_tags          = local.common_tags
}

# Security Group for Bastion Host (Public Subnet)
module "bastion_sg" {
  source = "../../modules/security-group"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "bastion-sg"
  sg_description = "Security group for Bastion Host"

  ingress_rules = [
    {
      description = "SSH access from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidr
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  common_tags = local.common_tags
}

# Security Group for ALB (Public Subnet)
module "alb_sg" {
  source = "../../modules/security-group"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "alb-sg"
  sg_description = "Security group for Application Load Balancer"

  ingress_rules = [
    {
      description = "HTTP access from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HTTPS access from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  common_tags = local.common_tags
}

# Security Group for Application Instances (Private Subnet)
module "app_sg" {
  source = "../../modules/security-group"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "app-sg"
  sg_description = "Security group for Application instances in private subnet"

  ingress_rules = [
    {
      description = "SSH from Bastion only"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "${module.bastion.bastion_private_ip}/32"
    },
    {
      description = "HTTP from ALB"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  common_tags = local.common_tags
}

# S3 Module - Application Bucket
module "s3_app" {
  source = "../../modules/s3"

  bucket_name            = "${var.project_name}-${var.environment}-app-${var.aws_region}-${data.aws_caller_identity.current.account_id}"
  environment            = var.environment
  enable_versioning      = true
  enable_lifecycle_rules = false
  common_tags            = local.common_tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  project_name   = var.project_name
  environment    = var.environment
  s3_bucket_arns = [module.s3_app.bucket_arn]
  common_tags    = local.common_tags
}

# Bastion Host Module (Public Subnet)
module "bastion" {
  source = "../../modules/ec2"

  project_name               = var.project_name
  environment                = var.environment
  create_bastion             = true
  instance_type              = var.bastion_instance_type
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.bastion_sg.security_group_id]
  iam_instance_profile       = module.iam.instance_profile_name
  key_name                   = var.key_name
  user_data_script           = templatefile("${path.module}/bastion-user-data.sh", {})
  enable_detailed_monitoring = false
  root_volume_size           = 8
  common_tags                = local.common_tags
}

# Application Load Balancer (Public Subnet)
module "alb" {
  source = "../../modules/alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.alb_sg.security_group_id]
  target_group_port          = 80
  target_group_protocol      = "HTTP"
  health_check_path          = "/"
  enable_deletion_protection = false
  common_tags                = local.common_tags
}

# Auto Scaling Group (Private Subnet)
module "asg" {
  source = "../../modules/asg"

  project_name               = var.project_name
  environment                = var.environment
  instance_type              = var.app_instance_type
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.app_sg.security_group_id]
  iam_instance_profile       = module.iam.instance_profile_name
  key_name                   = var.key_name
  user_data_script           = templatefile("${path.module}/app-user-data.sh", {
    environment    = var.environment
    s3_bucket_name = module.s3_app.bucket_id
    log_group_name = module.cloudwatch.log_group_name
  })
  enable_detailed_monitoring = false
  root_volume_size           = 8
  min_size                   = var.asg_min_size
  max_size                   = var.asg_max_size
  desired_capacity           = var.asg_desired_capacity
  target_group_arns          = [module.alb.target_group_arn]
  enable_scaling_policy      = true
  target_cpu_utilization     = 70
  common_tags                = local.common_tags
}

# CloudWatch Module
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  log_retention_days = 7
  instance_ids       = [] # ASG instances monitored separately
  create_alarms      = false
  common_tags        = local.common_tags
}

# Data source for AWS account ID
data "aws_caller_identity" "current" {}
