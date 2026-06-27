# Quick Start Guide

Get your multi-environment AWS infrastructure running in **10 minutes**!

---

## Prerequisites Checklist

- [ ] AWS Account (Free Tier)
- [ ] AWS CLI installed
- [ ] Terraform v1.9.0+ installed
- [ ] Git installed
- [ ] SSH key pair created in AWS (ap-south-1 region)

---

## Step 1: Configure AWS (2 minutes)

```bash
# Configure AWS credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (ap-south-1), Format (json)

# Verify access
aws sts get-caller-identity
```

---

## Step 2: Clone Repository (1 minute)

```bash
git clone <repository-url>
cd terraform-multi-environment-aws-infrastructure
chmod +x scripts/*.sh
```

---

## Step 3: Deploy Backend (2 minutes)

```bash
cd backend

# Create config
cat > terraform.tfvars << EOF
backend_bucket_name = "terraform-state-$(aws sts get-caller-identity --query Account --output text)"
EOF

# Deploy
terraform init
terraform apply -auto-approve

# Save bucket name
BUCKET=$(terraform output -raw s3_bucket_name)
cd ..
```

---

## Step 4: Update Backend Config (1 minute)

```bash
# Automatic update
sed -i "s/YOUR-BACKEND-BUCKET-NAME/${BUCKET}/g" environments/*/backend.hcl

# Or manually edit: environments/dev/backend.hcl
# Replace YOUR-BACKEND-BUCKET-NAME with your bucket name
```

---

## Step 5: Configure SSH Key (1 minute)

Edit `environments/dev/terraform.tfvars`:

```hcl
key_name = "my-key-pair"  # Replace with your key pair name
```

---

## Step 6: Deploy Development Environment (3 minutes)

```bash
./scripts/deploy.sh dev
```

Type `yes` when prompted.

---

## Step 7: Verify Deployment (2 minutes)

```bash
cd environments/dev

# Get ALB URL
terraform output alb_url

# Test application
curl $(terraform output -raw alb_url)
```

**Open in browser:** Copy the ALB URL and paste in browser. You should see a welcome page!

---

## What Gets Created

### Network (VPC)
- ✅ 1 VPC (10.0.0.0/16)
- ✅ 2 Public Subnets (Multi-AZ)
- ✅ 2 Private Subnets (Multi-AZ)
- ✅ 1 Internet Gateway
- ✅ 1 NAT Gateway
- ✅ Route Tables

### Compute
- ✅ 1 Bastion Host (Ubuntu 22.04, t3.micro) - Public Subnet
- ✅ 1-2 App Instances (Ubuntu 22.04, t3.micro) - Private Subnet
- ✅ 1 Application Load Balancer
- ✅ 1 Auto Scaling Group

### Security
- ✅ 3 Security Groups (Bastion, ALB, App)
- ✅ 1 IAM Role + Instance Profile
- ✅ Encrypted EBS volumes

### Storage & Monitoring
- ✅ 1 S3 Bucket (encrypted, versioned)
- ✅ 1 CloudWatch Log Group
- ✅ 1 CloudWatch Dashboard

**Region:** ap-south-1 (Mumbai)  
**Backend Region:** us-east-1  
**Total Cost (Free Tier):** $0.00/month  

---

## SSH Access

### Connect to Bastion

```bash
cd environments/dev

# Get bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip)

# SSH to bastion
ssh -i ~/path/to/my-key-pair.pem ubuntu@${BASTION_IP}
```

### Connect to Private Instance (from Bastion)

```bash
# Get private instance IP from AWS Console or:
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[?Tags[?Key==`Name` && contains(Value, `asg`)]].[PrivateIpAddress]' \
  --output text

# SSH from bastion
ssh ubuntu@<private-ip>
```

**Tip:** Use SSH agent forwarding:
```bash
# On local machine
ssh-add ~/path/to/my-key-pair.pem
ssh -A ubuntu@${BASTION_IP}

# Now you can SSH to private instances without copying key
```

---

## Next Steps

### 1. Explore AWS Console

- **EC2 Instances:** EC2 > Instances
- **Load Balancer:** EC2 > Load Balancers
- **Auto Scaling:** EC2 > Auto Scaling Groups
- **S3 Buckets:** S3 > Buckets
- **CloudWatch:** CloudWatch > Dashboards

### 2. Deploy Other Environments

```bash
# Stage environment
./scripts/deploy.sh stage

# Production environment
./scripts/deploy.sh prod
```

### 3. Use Interactive Manager

```bash
./scripts/switch-env.sh
```

### 4. Customize Infrastructure

Edit `environments/dev/terraform.tfvars`:

```hcl
project_name     = "my-project"
owner            = "Your-Name"
key_name         = "your-key-pair"
allowed_ssh_cidr = "your-ip/32"  # Get from: curl checkip.amazonaws.com
```

### 5. Test Auto Scaling

```bash
# SSH to bastion, then to app instance
# Generate CPU load
stress-ng --cpu 1 --timeout 300s

# Watch CloudWatch metrics
# EC2 > Auto Scaling Groups > Monitoring
```

---

## Cleanup

### Destroy Environment

```bash
./scripts/destroy.sh dev
```

Type `yes` when prompted.

### Destroy All

```bash
./scripts/destroy.sh dev
./scripts/destroy.sh stage
./scripts/destroy.sh prod

# Optional: Destroy backend
cd backend && terraform destroy
```

### Verify Cleanup

```bash
# Check for remaining resources
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=multi-env-infra" \
  --query 'Reservations[].Instances[?State.Name!=`terminated`].InstanceId'

# Check cost
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity DAILY \
  --metrics "BlendedCost"
```

---

## Common Issues

### ❌ AWS credentials not found

```bash
aws configure
```

### ❌ Permission denied on scripts

```bash
chmod +x scripts/*.sh
```

### ❌ Bucket name already exists

Edit `backend/terraform.tfvars`:
```hcl
backend_bucket_name = "terraform-state-unique-name-$(date +%s)"
```

### ❌ Target group unhealthy

Wait 2-3 minutes for instances to pass health checks. Check:
```bash
# View logs
aws logs tail /aws/multi-env-infra/dev --follow

# Check instance status
aws ec2 describe-instance-status \
  --filters "Name=tag:Environment,Values=dev"
```

### ❌ Cannot SSH to bastion

1. Verify key exists in AWS: `aws ec2 describe-key-pairs --region ap-south-1`
2. Check security group allows your IP
3. Update `allowed_ssh_cidr` in `terraform.tfvars`

---

## Validation

### Check Infrastructure

```bash
# VPC
aws ec2 describe-vpcs --filters "Name=tag:Environment,Values=dev"

# EC2 Instances
aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev"

# Load Balancer
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `dev`)].DNSName'

# Target Health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names multi-env-infra-dev-tg \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

# S3 Buckets
aws s3 ls | grep multi-env-infra

# CloudWatch Log Groups
aws logs describe-log-groups --log-group-name-prefix /aws/multi-env-infra
```

---

## Getting Help

- 📖 Read [README.md](README.md) for complete documentation
- 📋 Check [STRUCTURE.md](STRUCTURE.md) for file details
- 🔍 Review CloudWatch logs in AWS Console
- 🐛 Create GitHub issue

---

## Congratulations! 🎉

You've successfully deployed a production-grade multi-environment AWS infrastructure!

**What you've accomplished:**
- ✅ Multi-AZ VPC with public/private subnets
- ✅ Load-balanced auto-scaling application
- ✅ Secure bastion host access
- ✅ CloudWatch monitoring
- ✅ Infrastructure as Code with Terraform

**Your infrastructure includes:**
- High availability (Multi-AZ)
- Auto scaling (CPU-based)
- Load balancing (ALB)
- Secure access (Bastion + Private subnets)
- Monitoring & logging (CloudWatch)
- Cost optimization (Free Tier)

---

**⚠️ Remember: Destroy resources when done to avoid charges!**

```bash
./scripts/destroy.sh dev
```

**Happy cloud engineering!** 🚀
