# Development Environment - Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-env-infra"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "DevOps-Team"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "bastion_instance_type" {
  description = "Instance type for Bastion Host"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "Instance type for Application instances"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
  type        = number
  default     = 1
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access to Bastion"
  type        = string
  default     = "0.0.0.0/0"
}
