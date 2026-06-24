# Staging Environment - Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# EC2 Outputs
output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "instance_public_ips" {
  description = "List of EC2 public IP addresses"
  value       = module.ec2.instance_public_ips
}

output "instance_public_dns" {
  description = "List of EC2 public DNS names"
  value       = module.ec2.instance_public_dns
}

# S3 Outputs
output "s3_app_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = module.s3_app.bucket_id
}

output "s3_app_bucket_arn" {
  description = "ARN of the application S3 bucket"
  value       = module.s3_app.bucket_arn
}

# IAM Outputs
output "iam_role_name" {
  description = "Name of the IAM role"
  value       = module.iam.iam_role_name
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.iam.instance_profile_name
}

# CloudWatch Outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch.log_group_name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.cloudwatch.dashboard_name
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the security group"
  value       = module.security_group.security_group_id
}
