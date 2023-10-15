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

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

resource "aws_s3_bucket" "s3infra" {
  bucket = "s3-infra-${var.env}-01"
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "s3infra" {
  bucket = aws_s3_bucket.s3infra.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "s3infrarep" {
  provider = aws.london
  bucket = "s3-infra-${var.env}-01-replica"
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "s3infrarep" {
  provider = aws.london
  bucket = aws_s3_bucket.s3infrarep.id
  versioning_configuration {
    status = "Enabled"
  }
}

