# CloudWatch Module - Main Configuration
# Creates CloudWatch log groups and dashboards for monitoring

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/${var.project_name}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-log-group"
    }
  )
}

# CloudWatch Dashboard - Only create if instance_ids is not empty or if we have ASG
resource "aws_cloudwatch_dashboard" "main" {
  count = length(var.instance_ids) > 0 || var.autoscaling_group_name != "" ? 1 : 0

  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = var.autoscaling_group_name != "" ? jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "GroupInServiceInstances", ".", "."],
            [".", "GroupMinSize", ".", "."],
            [".", "GroupMaxSize", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Auto Scaling Group Metrics"
        }
        width  = 12
        height = 6
        x      = 0
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }]
          ]
          period = 300
          region = var.aws_region
          title  = "ALB Metrics"
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      }
    ]
    }) : jsonencode({
    widgets = [
      {
        type = "text"
        properties = {
          markdown = "## ${var.project_name}-${var.environment}\n\nMonitoring Dashboard\n\nNo instances currently being monitored."
        }
        width  = 24
        height = 6
        x      = 0
        y      = 0
      }
    ]
  })
}

# CloudWatch Metric Alarm - High CPU (for individual instances if provided)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.create_alarms && length(var.instance_ids) > 0 ? length(var.instance_ids) : 0

  alarm_name          = "${var.project_name}-${var.environment}-high-cpu-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-high-cpu-alarm-${count.index + 1}"
    }
  )
}

# CloudWatch Metric Alarm - ASG High CPU
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  count = var.create_alarms && var.autoscaling_group_name != "" ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ASG average CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-asg-high-cpu-alarm"
    }
  )
}
