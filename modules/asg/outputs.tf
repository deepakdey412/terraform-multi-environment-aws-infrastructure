# Auto Scaling Group Module - Outputs

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the Launch Template"
  value       = aws_launch_template.main.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.main.latest_version
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "ami_id" {
  description = "AMI ID used for instances"
  value       = data.aws_ami.ubuntu.id
}
