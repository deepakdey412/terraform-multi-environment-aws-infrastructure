# EC2 Module - Main Configuration
# Creates EC2 instances with user data, monitoring, and instance profiles

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Create EC2 Instances
resource "aws_instance" "main" {
  count = var.instance_count

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  user_data = var.user_data_script

  monitoring = var.enable_detailed_monitoring

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-instance-${count.index + 1}-root"
      }
    )
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = merge(
    var.common_tags,
    {
      Name  = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
      Index = count.index + 1
    }
  )
}

# Elastic IP (Optional - for Production)
resource "aws_eip" "main" {
  count = var.allocate_eip ? var.instance_count : 0

  instance = aws_instance.main[count.index].id
  domain   = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-eip-${count.index + 1}"
    }
  )
}
