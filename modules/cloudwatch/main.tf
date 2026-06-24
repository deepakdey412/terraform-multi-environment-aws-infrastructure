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

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "CPUUtilization",
              {
                stat   = "Average"
                label  = "Instance ${instance_id}"
                region = var.aws_region
              },
              { dimensions = { InstanceId = instance_id } }
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
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
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "NetworkIn",
              {
                stat   = "Sum"
                label  = "Instance ${instance_id}"
                region = var.aws_region
              },
              { dimensions = { InstanceId = instance_id } }
            ]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Network In (Bytes)"
        }
        width  = 12
        height = 6
        x      = 12
        y      = 0
      },
      {
        type = "metric"
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "NetworkOut",
              {
                stat   = "Sum"
                label  = "Instance ${instance_id}"
                region = var.aws_region
              },
              { dimensions = { InstanceId = instance_id } }
            ]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Network Out (Bytes)"
        }
        width  = 12
        height = 6
        x      = 0
        y      = 6
      },
      {
        type = "metric"
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "StatusCheckFailed",
              {
                stat   = "Maximum"
                label  = "Instance ${instance_id}"
                region = var.aws_region
              },
              { dimensions = { InstanceId = instance_id } }
            ]
          ]
          period = 300
          stat   = "Maximum"
          region = var.aws_region
          title  = "Status Check Failed"
        }
        width  = 12
        height = 6
        x      = 12
        y      = 6
      }
    ]
  })
}

# CloudWatch Metric Alarm - High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.create_alarms ? length(var.instance_ids) : 0

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

# CloudWatch Metric Alarm - Status Check Failed
resource "aws_cloudwatch_metric_alarm" "status_check" {
  count = var.create_alarms ? length(var.instance_ids) : 0

  alarm_name          = "${var.project_name}-${var.environment}-status-check-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This metric monitors EC2 status checks"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-status-check-alarm-${count.index + 1}"
    }
  )
}
