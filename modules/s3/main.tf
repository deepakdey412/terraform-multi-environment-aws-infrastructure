# S3 Module - Main Configuration
# Creates S3 buckets with versioning, encryption, and access controls

# Create S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

  tags = merge(
    var.common_tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
    }
  )
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Rules (Optional - helps reduce costs)
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = var.enable_lifecycle_rules ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    id     = "transition-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "delete-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Bucket Policy (Optional)
resource "aws_s3_bucket_policy" "main" {
  count = var.bucket_policy != "" ? 1 : 0

  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy
}
