terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.21.0"
      #version = "~= 4.50"  for production
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "s3infra" {
  bucket = "s3-infra-${var.env}-01"
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3infra" {
  bucket                  = aws_s3_bucket.s3infra.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  acl    = "public-read"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  rule {
    status = "Enabled"
    id     = "${aws_s3_bucket.s3infra.bucket}-rule"
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    filter {
      #prefix = null
      prefix = "file"
    }
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
}
