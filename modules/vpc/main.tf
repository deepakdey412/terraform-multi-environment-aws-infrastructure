# VPC Module - Main Configuration
# Creates VPC with Public and Private Subnets following AWS best practices
# Public Subnet: Bastion Host, NAT Gateway, ALB
# Private Subnet: Application EC2 instances (Auto Scaling Group)

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}

# Get available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create Public Subnets (for Bastion, NAT Gateway, ALB)
resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
      Tier = "Public"
    }
  )
}

# Create Private Subnets (for Application EC2 instances)
resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
      Tier = "Private"
    }
  )
}

# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create NAT Gateway in first Public Subnet
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
      Type = "Public"
    }
  )
}

# Create Private Route Table
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt"
      Type = "Private"
    }
  )
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count = var.enable_nat_gateway ? var.private_subnet_count : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# VPC Flow Logs (Optional - Free Tier friendly)
resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = var.flow_logs_role_arn
  log_destination = var.flow_logs_destination
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-flow-logs"
    }
  )
}
