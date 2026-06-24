# Security Group Module - Main Configuration
# Creates security groups with customizable ingress and egress rules

resource "aws_security_group" "main" {
  name        = "${var.project_name}-${var.environment}-${var.sg_name}"
  description = var.sg_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.sg_name}"
    }
  )
}

# Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "ingress" {
  count = length(var.ingress_rules)

  security_group_id = aws_security_group.main.id
  description       = var.ingress_rules[count.index].description

  from_port   = var.ingress_rules[count.index].from_port
  to_port     = var.ingress_rules[count.index].to_port
  ip_protocol = var.ingress_rules[count.index].protocol
  cidr_ipv4   = var.ingress_rules[count.index].cidr_blocks

  tags = {
    Name = "${var.sg_name}-ingress-${count.index + 1}"
  }
}

# Egress Rules
resource "aws_vpc_security_group_egress_rule" "egress" {
  count = length(var.egress_rules)

  security_group_id = aws_security_group.main.id
  description       = var.egress_rules[count.index].description

  from_port   = var.egress_rules[count.index].from_port
  to_port     = var.egress_rules[count.index].to_port
  ip_protocol = var.egress_rules[count.index].protocol
  cidr_ipv4   = var.egress_rules[count.index].cidr_blocks

  tags = {
    Name = "${var.sg_name}-egress-${count.index + 1}"
  }
}
