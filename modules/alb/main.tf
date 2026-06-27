# Application Load Balancer Module - Main Configuration
# Creates internet-facing ALB in Public Subnets

# Create Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

# Create Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    protocol            = var.target_group_protocol
    matcher             = var.health_check_matcher
  }

  deregistration_delay = 30

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-tg"
    }
  )
}

# Create HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-http-listener"
    }
  )
}
