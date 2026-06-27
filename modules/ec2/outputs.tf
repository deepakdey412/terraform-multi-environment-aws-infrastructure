# EC2 Module - Outputs
# Outputs for Bastion Host

output "bastion_instance_id" {
  description = "ID of the Bastion Host"
  value       = var.create_bastion ? aws_instance.bastion[0].id : null
}

output "bastion_instance_arn" {
  description = "ARN of the Bastion Host"
  value       = var.create_bastion ? aws_instance.bastion[0].arn : null
}

output "bastion_public_ip" {
  description = "Public IP address of Bastion Host"
  value       = var.create_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Private IP address of Bastion Host"
  value       = var.create_bastion ? aws_instance.bastion[0].private_ip : null
}

output "bastion_public_dns" {
  description = "Public DNS name of Bastion Host"
  value       = var.create_bastion ? aws_instance.bastion[0].public_dns : null
}

output "ami_id" {
  description = "AMI ID used for Bastion Host"
  value       = data.aws_ami.ubuntu.id
}
