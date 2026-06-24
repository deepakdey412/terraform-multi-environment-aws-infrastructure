# Quick Start Guide

Get up and running with this project in under 10 minutes!

## Prerequisites Checklist

- [ ] AWS Account created
- [ ] AWS CLI installed and configured
- [ ] Terraform installed (v1.9.0+)
- [ ] Git installed
- [ ] Bash shell available

## 5-Minute Setup

### 1. Configure AWS (2 minutes)

```bash
# Configure AWS credentials
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Format (json)

# Verify access
aws sts get-caller-identity
```

### 2. Clone and Setup (1 minute)

```bash
# Clone repository
cd terraform-multi-environment-aws-infrastructure

# Make scripts executable
chmod +x scripts/*.sh
```

### 3. Deploy Backend (2 minutes)

```bash
# Navigate to backend
cd backend

# Create variables file
cat > terraform.tfvars << EOF
backend_bucket_name = "terraform-state-$(aws sts get-caller-identity --query Account --output text)"
EOF

# Deploy backend
terraform init
terraform apply -auto-approve

# Save bucket name
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
echo $BUCKET_NAME

# Return to root
cd ..
```

### 4. Update Backend Config (1 minute)

```bash
# Update all environment backend configs
sed -i "s/YOUR-BACKEND-BUCKET-NAME/${BUCKET_NAME}/g" environments/*/backend.hcl

# Or manually edit: environments/dev/backend.hcl
```

### 5. Deploy Development Environment (3 minutes)

```bash
# Deploy using automation script
./scripts/deploy.sh dev

# Type 'yes' when prompted
```

## What Gets Created

- ✅ 1 VPC (10.0.0.0/16)
- ✅ 2 Public Subnets (Multi-AZ)
- ✅ 1 Internet Gateway
- ✅ 1 Security Group
- ✅ 1 EC2 Instance (t2.micro)
- ✅ 1 S3 Bucket (application)
- ✅ 1 IAM Role + Instance Profile
- ✅ 1 CloudWatch Log Group
- ✅ 1 CloudWatch Dashboard

**Total: ~10 resources | Cost: $0.00 (Free Tier)**

## Verify Deployment

```bash
# Get instance IP
cd environments/dev
terraform output instance_public_ips

# Open in browser
# http://<instance-ip>

# You should see a welcome page!
```

## Next Steps

1. **Explore CloudWatch Dashboard**
   - AWS Console → CloudWatch → Dashboards

2. **Check S3 Bucket**
   - AWS Console → S3 → Buckets

3. **View EC2 Instance**
   - AWS Console → EC2 → Instances

4. **Deploy to Stage**
   ```bash
   ./scripts/deploy.sh stage
   ```

5. **Deploy to Production**
   ```bash
   ./scripts/deploy.sh prod
   ```

## Cleanup When Done

```bash
# Destroy environment
./scripts/destroy.sh dev

# Type 'yes' when prompted

# Optionally destroy backend
cd backend
terraform destroy
```

## Common Issues

**Issue:** AWS credentials not found
```bash
# Solution
aws configure
```

**Issue:** Bucket name already exists
```bash
# Solution: Use unique name with account ID
backend_bucket_name = "terraform-state-UNIQUE-ID-$(date +%s)"
```

**Issue:** Permission denied on scripts
```bash
# Solution
chmod +x scripts/*.sh
```

## Getting Help

- 📖 Full documentation: See [README.md](README.md)
- 🐛 Issues: Create GitHub issue
- 💬 Questions: Check README FAQ section

## Congratulations! 🎉

You've successfully deployed a multi-environment AWS infrastructure!

**What you've learned:**
- Terraform basics
- AWS infrastructure
- Remote state management
- Automation with Bash
- DevOps best practices

**Next challenges:**
- Deploy to stage and prod
- Customize the infrastructure
- Add your own application
- Set up GitHub Actions CI/CD
- Explore the modules

---

**⚠️ Remember to destroy resources when done to avoid costs!**

```bash
./scripts/destroy.sh dev
./scripts/destroy.sh stage
./scripts/destroy.sh prod
```
