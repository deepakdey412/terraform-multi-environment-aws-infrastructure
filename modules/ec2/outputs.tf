# EC2 Module - Outputs

output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.main[*].id
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = aws_instance.main[*].arn
}

output "instance_public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.main[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.main[*].private_ip
}

output "instance_public_dns" {
  description = "List of public DNS names"
  value       = aws_instance.main[*].public_dns
}

output "instance_private_dns" {
  description = "List of private DNS names"
  value       = aws_instance.main[*].private_dns
}

output "elastic_ips" {
  description = "List of Elastic IP addresses"
  value       = aws_eip.main[*].public_ip
}

output "ami_id" {
  description = "AMI ID used for instances"
  value       = data.aws_ami.amazon_linux.id
}
