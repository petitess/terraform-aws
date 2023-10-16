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
  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "s3infrahtml" {
    bucket          = aws_s3_bucket.s3infra.id
    key             = "index.html"
    source          = "index.html"
    content_type    = "text/html"
    acl             = "public-read"
}