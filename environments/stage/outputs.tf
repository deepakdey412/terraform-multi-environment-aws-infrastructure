# Development Environment - Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "Elastic IP of NAT Gateway"
  value       = module.vpc.nat_gateway_eip
}

# Bastion Host Outputs
output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_instance_id" {
  description = "Instance ID of Bastion Host"
  value       = module.bastion.bastion_instance_id
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = module.alb.target_group_arn
}

# Auto Scaling Group Outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.asg.launch_template_id
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

# Application Access
output "application_url" {
  description = "URL to access the application via ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

# SSH Access Instructions
output "ssh_to_bastion" {
  description = "Command to SSH into Bastion Host"
  value       = "ssh -i your-key.pem ec2-user@${module.bastion.bastion_public_ip}"
}
