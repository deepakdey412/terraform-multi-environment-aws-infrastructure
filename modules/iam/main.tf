# IAM Module - Main Configuration
# Creates IAM roles, policies, and instance profiles for EC2 instances

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-role"
    }
  )
}

# Trust Policy for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Policy for EC2 - S3 Access
resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "${var.project_name}-${var.environment}-ec2-s3-policy"
  description = "Policy for EC2 to access S3 buckets"
  policy      = data.aws_iam_policy_document.ec2_s3_policy.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-s3-policy"
    }
  )
}

# S3 Access Policy Document
data "aws_iam_policy_document" "ec2_s3_policy" {
  statement {
    sid    = "ListBuckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = var.s3_bucket_arns
  }

  statement {
    sid    = "ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [for arn in var.s3_bucket_arns : "${arn}/*"]
  }
}

# IAM Policy for EC2 - CloudWatch Logs
resource "aws_iam_policy" "ec2_cloudwatch_policy" {
  name        = "${var.project_name}-${var.environment}-ec2-cloudwatch-policy"
  description = "Policy for EC2 to write logs to CloudWatch"
  policy      = data.aws_iam_policy_document.ec2_cloudwatch_policy.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-cloudwatch-policy"
    }
  )
}

# CloudWatch Logs Policy Document
data "aws_iam_policy_document" "ec2_cloudwatch_policy" {
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }
}

# Attach S3 Policy to Role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

# Attach CloudWatch Policy to Role
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_cloudwatch_policy.arn
}

# Attach AWS Managed Policy - SSM (for Systems Manager access)
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ec2-profile"
    }
  )
}
