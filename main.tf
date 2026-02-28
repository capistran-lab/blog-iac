# --- Terraform State & Providers Configuration ---

terraform {
  # Backend configuration for remote state management
  backend "s3" {
    bucket         = "ucapistran-terraform-state"
    key            = "blog/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ucapistran-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Cambiamos de 5.0 a 6.0
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Frontend Hosting Bucket (Next.js Static Export) ---

resource "aws_s3_bucket" "tf-blog-website-bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.project_name
    Environment = var.environment
  }
}

# Configures the bucket to serve a static website
resource "aws_s3_bucket_website_configuration" "blog_config" {
  bucket = aws_s3_bucket.tf-blog-website-bucket.id

  index_document {
    suffix = "index.html"
  }

  # Redirects errors to index.html to support Next.js client-side routing (SPA)
  error_document {
    key = "index.html"
  }
}

# Public access block configuration for static hosting
resource "aws_s3_bucket_public_access_block" "blog_public_access" {
  bucket = aws_s3_bucket.tf-blog-website-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Policy to allow public read access to all objects in the hosting bucket
# --- CloudFront Access Policy ---
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.tf-blog-website-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.tf-blog-website-bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website_distribution.arn
          }
        }
      }
    ]
  })
}
