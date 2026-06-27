# Auto Scaling Group Module - Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs for Auto Scaling Group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "user_data_script" {
  description = "User data script for instance initialization"
  type        = string
  default     = ""
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Type of root volume"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 8
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

variable "target_group_arns" {
  description = "List of target group ARNs for ALB"
  type        = list(string)
  default     = []
}

variable "enable_scaling_policy" {
  description = "Enable auto scaling policy"
  type        = bool
  default     = true
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for scaling"
  type        = number
  default     = 70
}

variable "key_name" {
  description = "SSH key pair name for EC2 instance access"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
