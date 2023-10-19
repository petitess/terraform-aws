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

data "aws_region" "current" {}

resource "aws_cloudfront_origin_access_control" "infra" {
  name                              = "orginAccess"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "infra" {
  tags    = var.tags
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.s3infra.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.infra.id
    origin_id = "s3Orgin"
  }
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "s3Orgin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
