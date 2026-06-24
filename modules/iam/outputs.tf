# IAM Module - Outputs

output "iam_role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.ec2_role.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.ec2_role.name
}

output "instance_profile_id" {
  description = "ID of the instance profile"
  value       = aws_iam_instance_profile.ec2_profile.id
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "s3_policy_arn" {
  description = "ARN of the S3 access policy"
  value       = aws_iam_policy.ec2_s3_policy.arn
}

output "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch policy"
  value       = aws_iam_policy.ec2_cloudwatch_policy.arn
}
