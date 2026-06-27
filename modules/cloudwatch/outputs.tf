# CloudWatch Module - Outputs

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = length(aws_cloudwatch_dashboard.main) > 0 ? aws_cloudwatch_dashboard.main[0].dashboard_name : ""
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = length(aws_cloudwatch_dashboard.main) > 0 ? aws_cloudwatch_dashboard.main[0].dashboard_arn : ""
}

output "alarm_arns" {
  description = "List of CloudWatch alarm ARNs"
  value       = concat(aws_cloudwatch_metric_alarm.high_cpu[*].arn, aws_cloudwatch_metric_alarm.asg_high_cpu[*].arn)
}
