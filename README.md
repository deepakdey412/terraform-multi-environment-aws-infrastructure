# Terraform Multi-Environment AWS Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.9.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Free_Tier-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu)](https://ubuntu.com/)

Production-ready Infrastructure as Code (IaC) for automated multi-environment AWS deployment using Terraform, featuring modular architecture, CI/CD automation, and comprehensive monitoring.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Cost Optimization](#cost-optimization)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Use Cases](#use-cases)
- [Support](#support)

---

## Overview

Enterprise-grade Terraform infrastructure demonstrating DevOps best practices:

- **Multi-Environment**: Isolated Dev, Stage, and Prod environments
- **Modular Design**: 6 reusable Terraform modules
- **Full Automation**: One-command deployment with bash scripts
- **CI/CD Ready**: GitHub Actions pipeline included
- **Security Hardened**: IAM roles, encryption, IMDSv2
- **Monitoring**: CloudWatch logs, metrics, and dashboards
- **Free Tier Optimized**: Designed for AWS Free Tier (Mumbai region)

### What You'll Learn

✅ Infrastructure as Code with Terraform  
✅ AWS multi-environment architecture  
✅ DevOps automation and CI/CD  
✅ Cloud security best practices  
✅ Cost optimization strategies  
✅ Remote state management  

---

## Architecture

```
                              Internet
                                 │
                        Internet Gateway
                                 │
              ┌──────────────────┴──────────────────────────────┐
              │            VPC (10.x.0.0/16)                    │
              │                                                  │
              │  ┌─────────────────────┬────────────────────┐  │
              │  │  Public Subnet AZ-1 │ Public Subnet AZ-2 │  │
              │  │  (ap-south-1a)      │ (ap-south-1b)      │  │
              │  │                     │                    │  │
              │  │  - Bastion Host     │                    │  │
              │  │  - NAT Gateway      │                    │  │
              │  │  - ALB (spans both AZs)                  │  │
              │  └──────────┬──────────┴────────┬───────────┘  │
              │             │                   │              │
              │             │  NAT Gateway      │              │
              │             │       ↓           │              │
              │  ┌──────────┴──────────┬────────┴───────────┐  │
              │  │ Private Subnet AZ-1 │ Private Subnet AZ-2│  │
              │  │ (ap-south-1a)       │ (ap-south-1b)      │  │
              │  │                     │                    │  │
              │  │ - App Instance 1    │ - App Instance 2   │  │
              │  │   (from ASG)        │   (from ASG)       │  │
              │  └─────────────────────┴────────────────────┘  │
              │                                                  │
              └──────────────────────────────────────────────────┘
                           │              │
                      CloudWatch         S3
```

### **Traffic Flow:**

**Inbound (User → App):**
```
Internet → Internet Gateway → ALB (Public Subnets in both AZs) 
    → App Instances (Private Subnets in both AZs)
```

**Outbound (App → Internet):**
```
App Instances (Private Subnets) → NAT Gateway (Public Subnet AZ-1) 
    → Internet Gateway → Internet
```

**SSH Access:**
```
Your PC → Bastion Host (Public Subnet AZ-1) 
    → App Instances (Private Subnets in both AZs)
```

### Infrastructure Components

| Component | Dev | Stage | Prod | Purpose |
|-----------|-----|-------|------|---------|
| **VPC** | 1 | 1 | 1 | Network isolation |
| **Availability Zones** | 2 | 2 | 2 | ap-south-1a, ap-south-1b |
| **Public Subnets** | 2 | 2 | 2 | One per AZ (for Bastion, NAT, ALB) |
| **Private Subnets** | 2 | 2 | 2 | One per AZ (for App instances) |
| **Bastion Host** | 1 | 1 | 1 | SSH jump server in AZ-1 (t3.micro, Ubuntu 22.04) |
| **NAT Gateway** | 1 | 1 | 1 | In Public Subnet AZ-1 (for private subnet internet access) |
| **Application Load Balancer** | 1 | 1 | 1 | Spans both public subnets (AZ-1 & AZ-2) |
| **Auto Scaling Group** | 1-2 | 1-2 | 2-3 | Distributes instances across both private subnets |
| **S3 Buckets** | 1 | 1 | 1 | Application storage |
| **IAM Roles** | 1 | 1 | 1 | Instance permissions |
| **CloudWatch** | Yes | Yes | Yes | Logs, metrics, dashboards |

### **Key Architecture Points:**

1. **NAT Gateway Location:** 
   - 1 NAT Gateway in **Public Subnet AZ-1** (ap-south-1a)
   - Shared by ALL private subnets in both AZs
   - Cost optimization: Single NAT instead of one per AZ

2. **ALB Distribution:**
   - ALB is configured with **both public subnets** (AZ-1 & AZ-2)
   - AWS automatically creates network interfaces in both AZs
   - Provides high availability and automatic failover

3. **App Instances (ASG):**
   - ASG configured with **both private subnets** (AZ-1 & AZ-2)
   - AWS Auto Scaling distributes instances across both AZs
   - If AZ-1 fails, instances in AZ-2 continue serving traffic

4. **Bastion Host:**
   - Single bastion in **Public Subnet AZ-1**
   - Can SSH to app instances in **both** private subnets

**Region:** ap-south-1 (Mumbai) - Free Tier eligible for t3.micro  
**OS:** Ubuntu 22.04 LTS  
**Backend:** S3 (us-east-1) with versioning for state locking  

---

## Features

### Infrastructure
- 🌐 **Multi-AZ Deployment**: High availability across 2 availability zones
- 🔒 **Security**: Bastion host, private subnets, security groups, encryption
- 📈 **Auto Scaling**: Dynamic scaling based on CPU utilization
- ⚖️ **Load Balancing**: Application Load Balancer for traffic distribution
- 🌐 **NAT Gateway**: Secure outbound internet for private instances
- 💾 **S3 Storage**: Encrypted buckets with versioning
- 📊 **CloudWatch**: Comprehensive logging and monitoring
- 🔐 **IAM**: Least privilege access with instance profiles

### Automation
- 🚀 **One-Command Deployment**: `./scripts/deploy.sh dev`
- 🔄 **Environment Switcher**: Interactive menu for management
- ✅ **Automated Validation**: Pre-deployment checks
- 🎨 **Code Formatting**: Terraform fmt automation
- 🔧 **CI/CD Pipeline**: GitHub Actions workflow
- 🧹 **Easy Cleanup**: Safe resource destruction

### Developer Experience
- 📁 **Modular Architecture**: 6 reusable modules
- 📝 **Remote State**: S3 backend with locking
- 🎯 **Environment Parity**: Consistent configurations
- 📚 **Comprehensive Docs**: Step-by-step guides
- 🐛 **Error Handling**: Safety confirmations

---

## Prerequisites

### Required Software

```bash
# Terraform v1.9.0+
terraform --version

# AWS CLI v2.x
aws --version

# Git
git --version
```

**Installation:**

```bash
# macOS (Homebrew)
brew install terraform awscli git

# Linux (Ubuntu/Debian)
# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Windows (Chocolatey)
choco install terraform awscli git
```

### AWS Account Requirements

✅ Active AWS account (Free Tier eligible)  
✅ IAM user with programmatic access  
✅ Permissions: EC2, VPC, S3, IAM, CloudWatch, ELB  
✅ AWS CLI configured with credentials  

---

## Quick Start

**For detailed step-by-step setup instructions, see [QUICKSTART.md](QUICKSTART.md)**

### Summary (5 Minutes)

```bash
# 1. Configure AWS
aws configure

# 2. Clone repository
cd terraform-multi-environment-aws-infrastructure
chmod +x scripts/*.sh

# 3. Deploy backend
cd backend
cat > terraform.tfvars << EOF
backend_bucket_name = "terraform-state-$(aws sts get-caller-identity --query Account --output text)"
EOF
terraform init && terraform apply -auto-approve
BUCKET=$(terraform output -raw s3_bucket_name)
cd ..

# 4. Update backend configs
sed -i "s/YOUR-BACKEND-BUCKET-NAME/${BUCKET}/g" environments/*/backend.hcl

# 5. Deploy dev environment
./scripts/deploy.sh dev
```

**Next Steps:**
- Access ALB URL: `terraform output alb_url` from `environments/dev/`
- SSH to bastion: `ssh -i my-key-pair.pem ubuntu@<bastion-ip>`
- Deploy other environments: `./scripts/deploy.sh stage` or `./scripts/deploy.sh prod`

---

## Project Structure

```
terraform-multi-environment-aws-infrastructure/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                   # VPC, subnets, routing
│   ├── ec2/                   # Bastion host
│   ├── asg/                   # Auto Scaling Group
│   ├── alb/                   # Application Load Balancer
│   ├── security-group/        # Firewall rules
│   ├── s3/                    # S3 buckets
│   ├── iam/                   # IAM roles and policies
│   └── cloudwatch/            # Logging and monitoring
├── environments/               # Environment configurations
│   ├── dev/                   # Development
│   ├── stage/                 # Staging
│   └── prod/                  # Production
├── backend/                    # Remote state setup
├── scripts/                    # Automation scripts
│   ├── deploy.sh              # Deployment automation
│   ├── destroy.sh             # Resource cleanup
│   ├── validate.sh            # Configuration validation
│   ├── fmt.sh                 # Code formatting
│   └── switch-env.sh          # Interactive manager
├── .github/workflows/          # CI/CD pipeline
├── README.md                   # This file
├── QUICKSTART.md              # Quick setup guide
└── STRUCTURE.md               # Detailed file structure
```

### Modules Overview

| Module | Purpose | Resources |
|--------|---------|-----------|
| **vpc** | Networking | VPC, Subnets, IGW, NAT, Routes |
| **ec2** | Bastion host | EC2 instance in public subnet |
| **asg** | App instances | Launch template, Auto Scaling Group |
| **alb** | Load balancer | ALB, target group, listeners |
| **security-group** | Firewall | Security groups with rules |
| **s3** | Storage | Encrypted buckets with versioning |
| **iam** | Permissions | Roles, policies, instance profiles |
| **cloudwatch** | Monitoring | Log groups, dashboards, alarms |

---

## Cost Optimization

### Free Tier Usage (Mumbai Region)

**Monthly Cost (Year 1): $0.00**

| Service | Usage | Cost |
|---------|-------|------|
| EC2 (t3.micro) | 3 instances × 750h | ✅ Free |
| S3 Storage | < 5 GB | ✅ Free |
| CloudWatch Logs | < 5 GB | ✅ Free |
| Data Transfer | < 15 GB | ✅ Free |
| ALB | 750h/month | ✅ Free |

**After Free Tier (~Year 2):**

| Service | Monthly Cost |
|---------|--------------|
| EC2 (3 × t3.micro) | ~$9.00 |
| NAT Gateway | ~$32.00 |
| ALB | ~$16.00 |
| S3 + CloudWatch | ~$2.00 |
| **Total** | **~$59/month** |

### Cost Reduction Tips

1. **Destroy when not in use:**
   ```bash
   ./scripts/destroy.sh dev
   ```

2. **Use fewer environments:**
   - Start with dev only
   - Add stage/prod when needed

3. **Scale down ASG:**
   - Set min/max to 1 in tfvars

4. **Remove NAT Gateway** (if no outbound needed):
   - Comment out NAT in vpc module

5. **Monitor costs:**
   ```bash
   aws ce get-cost-and-usage \
     --time-period Start=2026-06-01,End=2026-06-30 \
     --granularity MONTHLY \
     --metrics "BlendedCost"
   ```

---

## Cleanup

### Destroy Environment

```bash
# Destroy dev
./scripts/destroy.sh dev

# Destroy all environments
./scripts/destroy.sh dev
./scripts/destroy.sh stage
./scripts/destroy.sh prod

# Destroy backend (optional)
cd backend && terraform destroy
```

### Verify Cleanup

```bash
# Check EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=multi-env-infra" \
  --query 'Reservations[].Instances[?State.Name!=`terminated`].InstanceId'

# Check VPCs
aws ec2 describe-vpcs \
  --filters "Name=tag:Project,Values=multi-env-infra"

# Check S3 buckets
aws s3 ls | grep multi-env-infra

# Check billing
aws ce get-cost-and-usage --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) --granularity DAILY --metrics "BlendedCost"
```

---

## Troubleshooting

### Common Issues

**Issue:** AWS credentials not found
```bash
# Solution
aws configure
```

**Issue:** Backend bucket already exists
```bash
# Solution: Use unique name
backend_bucket_name = "terraform-state-$(aws sts get-caller-identity --query Account --output text)-$(date +%s)"
```

**Issue:** Permission denied on scripts
```bash
# Solution
chmod +x scripts/*.sh
```

**Issue:** Target group shows unhealthy
```bash
# Check security group allows ALB → App traffic
# Verify app is running on port 80
# Check CloudWatch logs
aws logs tail /aws/multi-env-infra/dev --follow
```

**Issue:** Cannot SSH to bastion
```bash
# Verify key pair exists in AWS
aws ec2 describe-key-pairs --region ap-south-1

# Check security group allows your IP
# Update allowed_ssh_cidr in terraform.tfvars
```

**Issue:** Terraform state locked
```bash
# Force unlock (use with caution)
cd environments/dev
terraform force-unlock <lock-id>
```

### Getting Help

- 📖 Read [QUICKSTART.md](QUICKSTART.md) for setup
- 📋 Check [STRUCTURE.md](STRUCTURE.md) for file details
- 🔍 Review CloudWatch logs in AWS Console
- 🐛 Create GitHub issue for bugs

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## License

This project is open-source and available for educational purposes.

---

## Use Cases

### ✅ Portfolio Project
- Production-ready code
- Best practices demonstrated
- Comprehensive documentation

### ✅ Learning Platform
- Hands-on Terraform practice
- AWS services integration
- DevOps automation

### ✅ Reference Implementation
- Modular architecture
- Multi-environment strategy
- Security patterns

---

## Support

For questions or issues:
1. Check [QUICKSTART.md](QUICKSTART.md)
2. Review troubleshooting section above
3. Check AWS CloudWatch logs
4. Create a GitHub issue

---

**Created with ❤️ for the DevOps community**

**Good luck with your cloud journey!** 🚀
